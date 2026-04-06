import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js';
import { TransactionType } from '../../../generated/prisma/enums.js';
import { AuditLogRepository } from '../../audit-log/index.js';
import { InventoryRepository } from '../repository/inventory.repository.js';

import type { DbClient } from '../../../common/types/index.js';
import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  CreateInventoryDto,
  InventoryAdjustmentDto,
  InventoryAdjustmentResponseDto,
  InventoryDetailResponseDto,
  ListInventoriesQueryDto,
  ListInventoriesResponseDto,
  LowStockInventoriesResponseDto,
  UpdateInventoryDto,
  InventoryForTransactionData,
} from '../dto/inventory.dto.js';

/* Service xử lý business logic cho module Inventory.
Chịu trách nhiệm kiểm tra tính hợp lệ của dữ liệu,
áp dụng các ràng buộc nghiệp vụ
trước khi gọi Repository để thao tác với cơ sở dữ liệu. */
export class InventoryService {
  constructor(
    private readonly inventoryRepository: InventoryRepository,
    private readonly auditLogRepository: AuditLogRepository,
  ) {}

  createTxRepositories = (db: DbClient) => ({
    inventoryRepositoryTx: new InventoryRepository(db),
    auditLogRepositoryTx: new AuditLogRepository(db),
  });

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
    userId: string,
  ): Promise<InventoryDetailResponseDto> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    // MỞ TRANSACTION TẠI SERVICE
    return await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const updated = await inventoryRepositoryTx.updateOne(
        existingInventory.inventoryId,
        data,
      );

      await auditLogRepositoryTx.createLog({
        actionType: 'update',
        entityType: 'Inventory',
        userId,
        storeId,
        oldValue: {
          reorderThreshold: existingInventory.reorderThreshold,
          lastCount: existingInventory.lastCount,
        } as Prisma.InputJsonObject,
        newValue: {
          reorderThreshold: updated.reorderThreshold,
          lastCount: updated.lastCount,
          productPackageId: updated.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });

      return updated;
    });
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

    const changedQty = nextQuantity - existingInventory.quantity;

    return await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const updated = await inventoryRepositoryTx.adjustQuantity(
        existingInventory.inventoryId,
        nextQuantity,
      );

      await auditLogRepositoryTx.createLog({
        actionType: 'update',
        entityType: 'Inventory',
        userId,
        storeId,
        note: data.note ?? null,
        oldValue: {
          quantity: existingInventory.quantity,
        } as Prisma.InputJsonObject,
        newValue: {
          quantity: updated.quantity,
          changedQuantity: changedQty,
          adjustmentType: data.type,
          reason: data.reason ?? null,
          productPackageId: updated.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });

      return {
        productPackageId: updated.productPackage.productPackageId,
        previousQuantity: existingInventory.quantity,
        currentQuantity: updated.quantity,
        changedQuantity: changedQty,
        adjustmentType: data.type,
        reason: data.reason ?? null,
        note: data.note ?? null,
        updatedAt: updated.updatedAt,
      };
    });
  }

  async createInventory(
    storeId: string,
    data: CreateInventoryDto,
    userId: string,
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

    return await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      if (existingInventory) {
        if (existingInventory.activeStatus === 'active') {
          throw new CustomError({
            message:
              'Inventory record already exists and is active for this Product Package',
            status: StatusCodes.CONFLICT,
          });
        } else {
          const restored = await inventoryRepositoryTx.restoreInventory(
            existingInventory.inventoryId,
            data,
          );

          await auditLogRepositoryTx.createLog({
            actionType: 'create',
            entityType: 'Inventory',
            userId,
            storeId,
            oldValue: { activeStatus: 'inactive' } as Prisma.InputJsonObject,
            newValue: {
              activeStatus: 'active',
              quantity: restored.quantity,
              reorderThreshold: restored.reorderThreshold,
              lastCount: restored.lastCount,
              productPackageId: restored.productPackage.productPackageId,
            } as Prisma.InputJsonObject,
          });

          return restored;
        }
      }

      const created = await this.inventoryRepository.create(data);

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Inventory',
        userId,
        storeId,
        oldValue: null,
        newValue: {
          quantity: created.quantity,
          reorderThreshold: created.reorderThreshold,
          lastCount: created.lastCount,
          productPackageId: created.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });

      return created;
    });
  }

  async adjustInventoriesForTransaction(
    transactionId: string, // transactionId để ghi log
    transactionType: TransactionType,
    userId: string,
    storeId: string,
    items: InventoryForTransactionData[],
    db: DbClient,
  ): Promise<void> {
    // NOTE: Truyền db (TransactionClient) từ ngoài vào
    // NOTE: để đảm bảo tất cả query chạy trong cùng transaction
    const inventoryRepository = new InventoryRepository(db);

    // Lấy tất cả inventory đang active theo danh sách productPackageId
    const inventoryRecords =
      await inventoryRepository.findManyActiveByProductPackageIds(
        storeId,
        // map để lấy list productPackageId từ items
        items.map((item) => item.productPackageId),
      );

    // Tạo Map để lookup inventory theo productPackageId (O(1))
    const inventoryMap = new Map(
      inventoryRecords.map((inventory) => [
        inventory.productPackageId,
        inventory,
      ]),
    );

    // Transform items về data shape của hàm adjustManyForTransaction
    const inventoryItems = items.map((item) => {
      // Lấy inventory hiện tại từ Map
      const inventory = inventoryMap.get(item.productPackageId);

      // Defensive check (trên lý thuyết không xảy ra vì đã filter)
      if (!inventory) {
        throw new CustomError({
          message: 'Inventory not found for product package',
          status: StatusCodes.NOT_FOUND,
        });
      }

      // Nếu là export transaction, check `current quantity - new quantity < 0`
      if (transactionType === 'export') {
        if (inventory.quantity < item.quantity) {
          throw new CustomError({
            message: 'Insufficient inventory quantity',
            code: 'INSUFFICIENT_INVENTORY',
            status: StatusCodes.BAD_REQUEST,
          });
        }
      }

      // Trả về data shape của tham số items hàm repository
      return {
        inventoryId: inventory.inventoryId,
        productPackageId: item.productPackageId,
        quantity: inventory.quantity, // quantity hiện tại
        transactionQuantity: item.quantity, // quantity trong transaction
        unitPrice: item.unitPrice,
        transactionId: item.transactionId,
      };
    });

    await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      switch (transactionType) {
        case 'import': {
          await inventoryRepositoryTx.increaseManyForTransaction(
            inventoryItems,
          );

          for (const item of inventoryItems) {
            await auditLogRepositoryTx.createLog({
              actionType: 'update',
              entityType: 'Inventory',
              userId,
              storeId,
              note: null,
              oldValue: {
                quantity: item.quantity,
              } as Prisma.InputJsonObject,
              newValue: {
                quantity: item.quantity + item.transactionQuantity,
                changedQuantity: item.transactionQuantity,
                adjustmentType: transactionType,
                reason: 'import transaction',
                productPackageId: item.productPackageId,
                transactionId,
              } as Prisma.InputJsonObject,
            });
          }

          return;
        }
        case 'export': {
          const failedProductPackageIds =
            await inventoryRepositoryTx.decreaseManyForTransaction(
              inventoryItems,
            );

          // nếu có inventory bị lỗi khi trừ, return lỗi + packageId tương ứng
          if (failedProductPackageIds.size > 0) {
            throw new CustomError({
              message: 'Insufficient inventory quantity',
              code: 'INSUFFICIENT_INVENTORY',
              status: StatusCodes.BAD_REQUEST,
              details: {
                productPackageIds: failedProductPackageIds,
              },
            });
          }

          for (const item of inventoryItems) {
            await auditLogRepositoryTx.createLog({
              actionType: 'update',
              entityType: 'Inventory',
              userId,
              storeId,
              note: 'export transaction',
              oldValue: {
                quantity: item.quantity,
              } as Prisma.InputJsonObject,
              newValue: {
                quantity: item.quantity - item.transactionQuantity,
                changedQuantity: item.transactionQuantity,
                adjustmentType: transactionType,
                reason: null,
                productPackageId: item.productPackageId,
                transactionId,
              } as Prisma.InputJsonObject,
            });
          }

          return;
        }
        default:
          throw new CustomError({
            message: `Unsupported transaction type: ${transactionType}`,
            status: StatusCodes.BAD_REQUEST,
          });
      }
    });
  }

  async deleteInventory(
    storeId: string,
    productPackageId: string,
    userId: string,
  ): Promise<void> {
    const existingInventory = await this.getExistingInventory(
      storeId,
      productPackageId,
    );

    await prisma.$transaction(async (tx) => {
      const { inventoryRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      await inventoryRepositoryTx.delete(existingInventory.inventoryId);

      await auditLogRepositoryTx.createLog({
        actionType: 'delete',
        entityType: 'Inventory',
        userId,
        storeId,
        oldValue: { activeStatus: 'active' } as Prisma.InputJsonObject,
        newValue: {
          activeStatus: 'inactive',
          productPackageId: existingInventory.productPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });
    });
  }
}
