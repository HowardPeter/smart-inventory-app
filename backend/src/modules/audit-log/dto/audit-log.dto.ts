/* Định nghĩa các Data Transfer Object (DTO) cho module Audit Log.
Bao gồm các contract quy định cấu trúc dữ liệu đầu vào
(query params) và đầu ra (response) của API,
giúp đồng bộ kiểu dữ liệu giữa Frontend và Backend. */

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
