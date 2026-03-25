import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js';
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
import type { AdjustmentType } from '../inventory.type.js';

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
    }

    if (data.type === 'increase') {
      nextQuantity = existingInventory.quantity + data.quantity;
    }

    if (data.type === 'decrease') {
      nextQuantity = existingInventory.quantity - data.quantity;
    }

    if (nextQuantity < 0) {
      throw new CustomError({
        message: 'Inventory quantity cannot be negative',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    return await this.inventoryRepository.adjustQuantity(
      existingInventory.inventoryId,
      data.type,
      data.quantity,
      userId,
      data.reason,
      data.note,
    );
  }

  async adjustQuantity(
    inventoryId: string,
    type: AdjustmentType,
    quantity: number,
    userId: string,
    reason?: string | null,
    note?: string | null,
  ): Promise<InventoryAdjustmentResponseDto> {
    return await prisma.$transaction(async (tx) => {
      const currentInventory = await tx.inventory.findUnique({
        where: { inventoryId },
        select: {
          inventoryId: true,
          quantity: true,
          updatedAt: true,
          productPackageId: true,
        },
      });

      if (!currentInventory) {
        throw new Error('Inventory not found');
      }

      let nextQuantity = currentInventory.quantity;

      switch (type) {
        case 'set':
          nextQuantity = quantity;
          break;
        case 'increase':
          nextQuantity = currentInventory.quantity + quantity;
          break;
        case 'decrease':
          nextQuantity = currentInventory.quantity - quantity;
          break;
        default:
          nextQuantity = currentInventory.quantity;
          break;
      }

      const changedQty = nextQuantity - currentInventory.quantity;

      // Cập nhật số lượng
      const updatedInventory = await tx.inventory.update({
        where: { inventoryId },
        data: { quantity: nextQuantity },
        select: {
          quantity: true,
          updatedAt: true,
          productPackageId: true,
        },
      });

      // LƯU LỊCH SỬ ĐIỀU CHỈNH
      await tx.inventoryAdjustment.create({
        data: {
          inventoryId,
          previousQuantity: currentInventory.quantity,
          currentQuantity: updatedInventory.quantity,
          changedQuantity: changedQty,
          type: type,
          reason: reason ?? null,
          note: note ?? null,
          createdBy: userId,
        },
      });

      return {
        productPackageId: updatedInventory.productPackageId,
        previousQuantity: currentInventory.quantity,
        currentQuantity: updatedInventory.quantity,
        changedQuantity: changedQty,
        adjustmentType: type,
        reason: reason ?? null,
        note: note ?? null,
        updatedAt: updatedInventory.updatedAt,
      };
    });
  }

  async createInventory(
    storeId: string,
    data: CreateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    // 1. Kiểm tra ProductPackage có tồn tại và thuộc về Store này không
    const productPackage = await prisma.productPackage.findFirst({
      where: {
        productPackageId: data.productPackageId,
        product: { storeId },
      },
    });

    if (!productPackage) {
      throw new CustomError({
        message: 'Product Package not found or does not belong to this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // 2. Kiểm tra xem mã hàng này đã có kho chưa
    const existingInventory = await prisma.inventory.findFirst({
      where: { productPackageId: data.productPackageId },
    });

    if (existingInventory) {
      throw new CustomError({
        message: 'Inventory record already exists for this Product Package',
        status: StatusCodes.CONFLICT,
      });
    }

    // 3. Tiến hành tạo mới
    return await this.inventoryRepository.create(data);
  }

  async deleteInventory(
    storeId: string,
    productPackageId: string,
  ): Promise<void> {
    // Tái sử dụng hàm getExistingInventory để đảm bảo nó tồn tại và đúng Store
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    await this.inventoryRepository.delete(existingInventory.inventoryId);
  }
}
