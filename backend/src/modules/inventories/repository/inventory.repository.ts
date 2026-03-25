import {
  getPaginationSkip,
  normalizePagination,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js';
import { Prisma } from '../../../generated/prisma/client.js';

import type {
  CreateInventoryDto,
  InventoryAdjustmentResponseDto,
  InventoryDetailResponseDto,
  InventoryListItemDto,
  ListInventoriesQueryDto,
  UpdateInventoryDto,
} from '../dto/inventory.dto.js';
import type { AdjustmentType, InventoryStatus } from '../inventory.type.js';

const inventorySelect = {
  inventoryId: true,
  quantity: true,
  reorderThreshold: true,
  lastCount: true,
  updatedAt: true,
  productPackage: {
    select: {
      productPackageId: true,
      displayName: true,
      importPrice: true,
      sellingPrice: true,
      barcodeValue: true,
      barcodeType: true,
      unit: {
        select: {
          unitId: true,
          code: true,
          name: true,
        },
      },
      product: {
        select: {
          productId: true,
          name: true,
          imageUrl: true,
          brand: true,
          category: {
            select: {
              categoryId: true,
              name: true,
              description: true,
            },
          },
        },
      },
    },
  },
} satisfies Prisma.InventorySelect;

export class InventoryRepository {
  private mapInventoryStatus(
    quantity: number,
    reorderThreshold: number | null,
  ): InventoryStatus {
    if (quantity <= 0) {
      return 'outOfStock';
    }

    if (reorderThreshold !== null && quantity <= reorderThreshold) {
      return 'lowStock';
    }

    return 'inStock';
  }

  private toInventoryListItem(
    item: Prisma.InventoryGetPayload<{ select: typeof inventorySelect }>,
  ): InventoryListItemDto {
    return {
      inventoryId: item.inventoryId,
      quantity: item.quantity,
      reorderThreshold: item.reorderThreshold,
      lastCount: item.lastCount,
      updatedAt: item.updatedAt,
      inventoryStatus: this.mapInventoryStatus(
        item.quantity,
        item.reorderThreshold,
      ),
      productPackage: {
        productPackageId: item.productPackage.productPackageId,
        displayName: item.productPackage.displayName,
        importPrice: item.productPackage.importPrice
          ? Number(item.productPackage.importPrice)
          : null,
        sellingPrice: item.productPackage.sellingPrice
          ? Number(item.productPackage.sellingPrice)
          : null,
        barcodeValue: item.productPackage.barcodeValue,
        barcodeType: item.productPackage.barcodeType,
        unit: item.productPackage.unit,
        product: item.productPackage.product,
      },
    };
  }

  private buildInventoryWhere(
    storeId: string,
    query?: Partial<ListInventoriesQueryDto>,
  ): Prisma.InventoryWhereInput {
    const keyword = query?.keyword?.trim();
    const categoryId = query?.categoryId;

    return {
      activeStatus: 'active',
      productPackage: {
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
          ...(categoryId && {
            categoryId,
          }),
          ...(keyword && {
            OR: [
              { name: { contains: keyword, mode: 'insensitive' } },
              { brand: { contains: keyword, mode: 'insensitive' } },
              {
                productPackages: {
                  some: {
                    activeStatus: 'active',
                    OR: [
                      {
                        displayName: { contains: keyword, mode: 'insensitive' },
                      },
                      {
                        barcodeValue: {
                          contains: keyword,
                          mode: 'insensitive',
                        },
                      },
                    ],
                  },
                },
              },
            ],
          }),
        },
      },
    };
  }

  async findManyByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<{ items: InventoryListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const { sortBy = 'updatedAt', sortOrder = 'desc', inventoryStatus } = query;

    const where = this.buildInventoryWhere(storeId, query);

    const [rawItems, totalItems] = await prisma.$transaction([
      prisma.inventory.findMany({
        where,
        orderBy: { [sortBy]: sortOrder },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: inventorySelect,
      }),
      prisma.inventory.count({ where }),
    ]);

    let items = rawItems.map((item) => this.toInventoryListItem(item));

    if (inventoryStatus) {
      items = items.filter((item) => item.inventoryStatus === inventoryStatus);
    }

    return {
      items,
      totalItems: inventoryStatus ? items.length : totalItems,
    };
  }

  async findLowStockByStoreId(
    storeId: string,
    query: ListInventoriesQueryDto,
  ): Promise<{ items: InventoryListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const skip = getPaginationSkip({ page, limit });
    const { keyword, categoryId } = query;

    let keywordCondition = Prisma.empty;

    if (keyword) {
      const search = `%${keyword}%`;

      keywordCondition = Prisma.sql`AND (p.name ILIKE ${search} OR pp.display_name ILIKE ${search} OR pp.barcode_value ILIKE ${search})`;
    }

    let categoryCondition = Prisma.empty;

    if (categoryId) {
      categoryCondition = Prisma.sql`AND CAST(p.category_id AS uuid) = CAST(${categoryId} AS uuid)`;
    }

    const commonJoinsAndWhere = Prisma.sql`
      FROM "Inventory" i
      INNER JOIN "ProductPackage" pp ON i.product_package_id = pp.product_package_id
      INNER JOIN "Product" p ON pp.product_id = p.product_id
      WHERE CAST(p.store_id AS uuid) = CAST(${storeId} AS uuid)
        AND i.active_status = 'active'::"ActiveStatus"
        AND p.active_status = 'active'::"ActiveStatus"
        AND pp.active_status = 'active'::"ActiveStatus"
        AND i.reorder_threshold IS NOT NULL
        AND i.quantity <= i.reorder_threshold
        ${keywordCondition}
        ${categoryCondition}
    `;

    const totalRaw = await prisma.$queryRaw<{ count: bigint }[]>`
      SELECT COUNT(i.inventory_id) as count
      ${commonJoinsAndWhere}
    `;
    const totalItems = Number(totalRaw[0]?.count || 0);

    if (totalItems === 0) {
      return { items: [], totalItems: 0 };
    }

    const idsRaw = await prisma.$queryRaw<{ inventory_id: string }[]>`
      SELECT i.inventory_id
      ${commonJoinsAndWhere}
      ORDER BY i.updated_at DESC
      LIMIT ${limit} OFFSET ${skip}
    `;

    const inventoryIds = idsRaw.map((row) => row.inventory_id);

    const rawItems = await prisma.inventory.findMany({
      where: {
        inventoryId: { in: inventoryIds },
      },
      select: inventorySelect,
      orderBy: { updatedAt: 'desc' },
    });

    const items = rawItems.map((item) => this.toInventoryListItem(item));

    return { items, totalItems };
  }

  async findOneByProductPackageId(
    storeId: string,
    productPackageId: string,
  ): Promise<InventoryDetailResponseDto | null> {
    const inventory = await prisma.inventory.findFirst({
      where: {
        productPackageId,
        activeStatus: 'active',
        productPackage: {
          activeStatus: 'active',
          product: { storeId, activeStatus: 'active' },
        },
      },
      select: inventorySelect,
    });

    if (!inventory) {
      return null;
    }

    return this.toInventoryListItem(inventory);
  }

  async updateOne(
    inventoryId: string,
    data: UpdateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await prisma.inventory.update({
      where: { inventoryId },
      data,
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async adjustQuantity(
    storeId: string,
    inventoryId: string,
    type: AdjustmentType,
    nextQuantity: number,
    userId: string,
    reason?: string | null,
    note?: string | null,
  ): Promise<InventoryAdjustmentResponseDto | null> {
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
        return null;
      }

      const changedQty = nextQuantity - currentInventory.quantity;

      const updatedInventory = await tx.inventory.update({
        where: { inventoryId },
        data: { quantity: nextQuantity },
        select: {
          quantity: true,
          updatedAt: true,
          productPackageId: true,
        },
      });

      await tx.auditLog.create({
        data: {
          actionType: 'update',
          entityType: 'Inventory',
          userId: userId,
          storeId: storeId,
          oldValue: {
            quantity: currentInventory.quantity,
          },
          newValue: {
            quantity: updatedInventory.quantity,
            changedQuantity: changedQty,
            adjustmentType: type,
            reason: reason ?? null,
            note: note ?? null,
            productPackageId: currentInventory.productPackageId,
          },
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

  async checkProductPackageBelongsToStore(
    storeId: string,
    productPackageId: string,
  ): Promise<boolean> {
    const count = await prisma.productPackage.count({
      where: { productPackageId, product: { storeId } },
    });

    return count > 0;
  }

  async getInventoryStatusByProductPackageId(productPackageId: string) {
    return await prisma.inventory.findUnique({
      where: { productPackageId },
      select: { inventoryId: true, activeStatus: true },
    });
  }

  async restoreInventory(
    inventoryId: string,
    data: CreateInventoryDto,
  ): Promise<InventoryDetailResponseDto> {
    const inventory = await prisma.inventory.update({
      where: { inventoryId },
      data: {
        quantity: data.quantity,
        reorderThreshold: data.reorderThreshold ?? null,
        lastCount: data.lastCount ?? null,
        activeStatus: 'active',
      },
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async create(data: CreateInventoryDto): Promise<InventoryDetailResponseDto> {
    const inventory = await prisma.inventory.create({
      data: {
        productPackageId: data.productPackageId,
        quantity: data.quantity,
        reorderThreshold: data.reorderThreshold ?? null,
        lastCount: data.lastCount ?? null,
      },
      select: inventorySelect,
    });

    return this.toInventoryListItem(inventory);
  }

  async delete(inventoryId: string): Promise<void> {
    await prisma.inventory.update({
      where: { inventoryId },
      data: { activeStatus: 'inactive' },
    });
  }
}
