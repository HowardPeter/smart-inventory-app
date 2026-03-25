import {
  getPaginationSkip,
  normalizePagination,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js';

import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  InventoryAdjustmentListItemDto,
  ListAdjustmentsQueryDto,
} from '../dto/inventory-adjustment.dto.js';

const inventoryAdjustmentSelect = {
  inventoryAdjustmentId: true,
  inventoryId: true,
  previousQuantity: true,
  currentQuantity: true,
  changedQuantity: true,
  type: true,
  reason: true,
  note: true,
  createdBy: true,
  createdAt: true,
} satisfies Prisma.InventoryAdjustmentSelect;

export class InventoryAdjustmentRepository {
  async findManyByProductPackageId(
    storeId: string,
    productPackageId: string,
    query: ListAdjustmentsQueryDto,
  ): Promise<{ items: InventoryAdjustmentListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const { sortBy = 'createdAt', sortOrder = 'desc' } = query;

    // Điều kiện join lồng để đảm bảo bảo mật đúng Store
    const where: Prisma.InventoryAdjustmentWhereInput = {
      inventory: {
        productPackageId,
        productPackage: {
          product: {
            storeId,
          },
        },
      },
    };

    const [items, totalItems] = await prisma.$transaction([
      prisma.inventoryAdjustment.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: inventoryAdjustmentSelect,
      }),
      prisma.inventoryAdjustment.count({
        where,
      }),
    ]);

    return {
      items: items as InventoryAdjustmentListItemDto[],
      totalItems,
    };
  }
}
