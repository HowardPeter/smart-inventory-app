import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { AuditLogRepository } from '../repository/audit-log.repository.js';

import type {
  ListAuditLogsQueryDto,
  ListAuditLogsResponseDto,
} from '../dto/audit-log.dto.js';

export class AuditLogService {
  constructor(private readonly auditLogRepository: AuditLogRepository) {}

  async getAuditLogs(
    storeId: string,
    query: ListAuditLogsQueryDto,
  ): Promise<ListAuditLogsResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.auditLogRepository.findManyByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }
}
