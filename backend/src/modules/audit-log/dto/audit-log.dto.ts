import { Prisma } from '../../../generated/prisma/client.js';

import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../../common/types/index.js';
import type { AuditActionType } from '../../../generated/prisma/enums.js';
import type { AuditLog } from '../audit-log.type.js';

// NOTE: Tái sử dụng toàn bộ type gốc từ domain
// vì lịch sử kiểm toán cần trả về đầy đủ thông tin nguyên bản,
// không che giấu field nào
export type AuditLogListItemDto = AuditLog;

// DTO định nghĩa các tham số query trên URL,
// hỗ trợ filter lịch sử theo nhiều tiêu chí linh hoạt
export type ListAuditLogsQueryDto = ListPaginationQueryDto<'performedAt'> & {
  entityType?: string;
  actionType?: AuditActionType;
  userId?: string;
  startDate?: string;
  endDate?: string;
};

// DTO bọc danh sách kết quả trả về kèm theo thông tin phân trang (meta)
export type ListAuditLogsResponseDto =
  PaginationResponseDto<AuditLogListItemDto>;

export type CreateAuditLogDto = {
  actionType: 'create' | 'update' | 'delete';
  entityType: string | null;
  entityId: string | null;
  userId: string;
  storeId: string;
  oldValue: Prisma.InputJsonValue | null; // Sử dụng kiểu JSON Input của Prisma
  newValue: Prisma.InputJsonValue | null;
  note?: string | null;
};
