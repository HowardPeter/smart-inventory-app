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

/* Lớp Repository chịu trách nhiệm tương tác trực tiếp với
cơ sở dữ liệu (Prisma) cho module Audit Log.
Cung cấp các phương thức truy xuất lịch sử hệ thống
với khả năng lọc (filter) động linh hoạt. */
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

    // Xây dựng điều kiện truy vấn động (dynamic query)
    // dựa trên các tham số filter mà client gửi lên
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

    // NOTE: Chạy song song 2 truy vấn (lấy danh sách data và đếm tổng số)
    // trong cùng 1 transaction để tối ưu hiệu suất phân trang
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
