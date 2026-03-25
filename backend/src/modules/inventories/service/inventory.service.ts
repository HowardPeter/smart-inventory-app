import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { InventoryRepository } from '../repository/inventory.repository.js';

import type {
  CreateInventoryDto,
  InventoryAdjustmentDto,
  InventoryAdjustmentResponseDto,
  InventoryDetailResponseDto,
  ListInventoriesQueryDto,
  ListInventoriesResponseDto,
  LowStockInventoriesResponseDto,
  UpdateInventoryDto,
} from '../dto/inventory.dto.js';

export class InventoryService {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  private async getExistingInventory(
    storeId: string,
    productPackageId: string,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await this.inventoryRepository.findOneByProductPackageId(
      storeId,
      productPackageId,
    );

    if (!inventory) {
      throw new CustomError({
        message: 'Inventory not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return inventory;
  }

  async getInventoriesByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<ListInventoriesResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.inventoryRepository.findManyByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async getLowStockInventoriesByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<LowStockInventoriesResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.inventoryRepository.findLowStockByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async getInventoryByProductPackageId(
    storeId: string,
    productPackageId: string,
  ): Promise<InventoryDetailResponseDto> {
    return await this.getExistingInventory(storeId, productPackageId);
  }

  async updateInventory(
    storeId: string,
    productPackageId: string,
    data: UpdateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    return await this.inventoryRepository.updateOne(
      existingInventory.inventoryId,
      data,
    );
  }

  async adjustInventory(
    storeId: string,
    productPackageId: string,
    userId: string,
    data: InventoryAdjustmentDto,
  ): Promise<InventoryAdjustmentResponseDto> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    let nextQuantity = existingInventory.quantity;

    if (data.type === 'set') {
      nextQuantity = data.quantity;
    } else if (data.type === 'increase') {
      nextQuantity = existingInventory.quantity + data.quantity;
    } else if (data.type === 'decrease') {
      nextQuantity = existingInventory.quantity - data.quantity;
    }

    if (nextQuantity < 0) {
      throw new CustomError({
        message: 'Inventory quantity cannot be negative',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const result = await this.inventoryRepository.adjustQuantity(
      storeId,
      existingInventory.inventoryId,
      data.type,
      nextQuantity,
      userId,
      data.reason,
      data.note,
    );

    if (!result) {
      throw new CustomError({
        message: 'Failed to adjust inventory. Record might have been removed.',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return result;
  }

  async createInventory(
    storeId: string,
    data: CreateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const isBelongsToStore =
      await this.inventoryRepository.checkProductPackageBelongsToStore(
        storeId,
        data.productPackageId,
      );

    if (!isBelongsToStore) {
      throw new CustomError({
        message: 'Product Package not found or does not belong to this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const existingInventory =
      await this.inventoryRepository.getInventoryStatusByProductPackageId(
        data.productPackageId,
      );

    if (existingInventory) {
      if (existingInventory.activeStatus === 'active') {
        throw new CustomError({
          message:
            'Inventory record already exists and is active for this Product Package',
          status: StatusCodes.CONFLICT,
        });
      } else {
        return await this.inventoryRepository.restoreInventory(
          existingInventory.inventoryId,
          data,
        );
      }
    }

    return await this.inventoryRepository.create(data);
  }

  async deleteInventory(
    storeId: string,
    productPackageId: string,
  ): Promise<void> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    await this.inventoryRepository.delete(existingInventory.inventoryId);
  }
}
