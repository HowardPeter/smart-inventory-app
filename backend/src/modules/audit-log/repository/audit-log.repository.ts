import {
  getPaginationSkip,
  normalizePagination,
} from '../../../common/utils/index.js';
import { Prisma } from '../../../generated/prisma/client.js';

import type { DbClient } from '../../../common/types/index.js';
import type {
  AuditLogListItemDto,
  ListAuditLogsQueryDto,
} from '../dto/audit-log.dto.js';

export type CreateAuditLogPayload = {
  actionType: 'create' | 'update' | 'delete';
  entityType: string;
  userId: string;
  storeId: string;
  oldValue: Prisma.InputJsonValue | null; // Sử dụng kiểu JSON Input của Prisma
  newValue: Prisma.InputJsonValue | null;
  note?: string | null;
};

/* Lớp Repository chịu trách nhiệm tương tác trực tiếp với
cơ sở dữ liệu (Prisma) cho module Audit Log.
Cung cấp các phương thức truy xuất lịch sử hệ thống
với khả năng lọc (filter) động linh hoạt. */
export class AuditLogRepository {
  constructor(private readonly db: DbClient) {}

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
    const [items, totalItems] = await this.db.$transaction([
      this.db.auditLog.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
      }),
      this.db.auditLog.count({
        where,
      }),
    ]);

    return {
      items,
      totalItems,
    };
  }

  // NOTE: Hàm này nhận vào tx (Prisma.TransactionClient)
  // để chạy chung giao dịch với module khác
  async createLog(data: CreateAuditLogPayload): Promise<void> {
    await this.db.auditLog.create({
      data: {
        actionType: data.actionType,
        entityType: data.entityType,
        userId: data.userId,
        storeId: data.storeId,
        // Dùng Nullish Coalescing (??)
        // để tự động map null/undefined thành Prisma.DbNull
        oldValue: data.oldValue ?? Prisma.DbNull,
        newValue: data.newValue ?? Prisma.DbNull,
        note: data.note ?? null,
      },
    });
  }
}
