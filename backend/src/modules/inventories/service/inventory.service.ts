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

/* Service xử lý business logic cho module Inventory.
Chịu trách nhiệm kiểm tra tính hợp lệ của dữ liệu,
áp dụng các ràng buộc nghiệp vụ
trước khi gọi Repository để thao tác với cơ sở dữ liệu. */
export class InventoryService {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  // Hàm helper dùng chung để kiểm tra sự tồn tại của kho hàng,
  // ném lỗi 404 nếu không tìm thấy
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

    // NOTE: Tính toán số lượng tồn kho mới dựa trên loại điều chỉnh
    if (data.type === 'set') {
      nextQuantity = data.quantity;
    } else if (data.type === 'increase') {
      nextQuantity = existingInventory.quantity + data.quantity;
    } else if (data.type === 'decrease') {
      nextQuantity = existingInventory.quantity - data.quantity;
    }

    // Đảm bảo số lượng tồn kho không được phép âm theo quy định nghiệp vụ
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
    // Kiểm tra xem sản phẩm có thực sự thuộc quyền sở hữu
    // của cửa hàng hiện tại không
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

    // Kiểm tra trạng thái tồn kho hiện tại
    // để quyết định luồng tạo mới hoặc khôi phục
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
        // Khôi phục lại kho đã bị xóa mềm (inactive)
        // thay vì tạo mới để tránh lỗi duplicate khóa unique
        return await this.inventoryRepository.restoreInventory(
          existingInventory.inventoryId,
          data,
        );
      }
    }

    // Nếu dữ liệu chưa từng tồn tại, tiến hành tạo mới hoàn toàn
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
