import {
  getPaginationSkip,
  normalizePagination,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js';

import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  AuditLogListItemDto,
  ListAuditLogsQueryDto,
} from '../dto/audit-log.dto.js';

export class AuditLogRepository {
  async findManyByStoreId(
    storeId: string,
    query: ListAuditLogsQueryDto,
  ): Promise<{ items: AuditLogListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const {
      sortBy = 'performedAt',
      sortOrder = 'desc',
      entityType,
      actionType,
      userId,
      startDate,
      endDate,
    } = query;

    // Build query động
    const where: Prisma.AuditLogWhereInput = {
      storeId,
      ...(entityType && { entityType }),
      ...(actionType && { actionType }),
      ...(userId && { userId }),
      ...((startDate || endDate) && {
        performedAt: {
          ...(startDate && { gte: new Date(startDate) }),
          ...(endDate && { lte: new Date(endDate) }),
        },
      }),
    };

    const [items, totalItems] = await prisma.$transaction([
      prisma.auditLog.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
      }),
      prisma.auditLog.count({
        where,
      }),
    ]);

    return {
      items,
      totalItems,
    };
  }
}
