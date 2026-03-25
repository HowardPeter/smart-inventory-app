import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { AuditLogRepository } from '../repository/audit-log.repository.js';

import type {
  ListAuditLogsQueryDto,
  ListAuditLogsResponseDto,
} from '../dto/audit-log.dto.js';

/* Service xử lý business logic cho module Audit Log.
Đóng vai trò trung gian giữa Controller và Repository, chịu trách nhiệm
chuẩn hóa các tham số đầu vào và định dạng
kết quả trả về theo chuẩn hệ thống. */
export class AuditLogService {
  constructor(private readonly auditLogRepository: AuditLogRepository) {}

  async getAuditLogs(
    storeId: string,
    query: ListAuditLogsQueryDto,
  ): Promise<ListAuditLogsResponseDto> {
    // Chuẩn hóa các tham số phân trang (page, limit)
    // về kiểu số học hợp lệ trước khi query DB
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.auditLogRepository.findManyByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }
}
