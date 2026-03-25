import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../../common/types/index.js';
import type { AuditActionType } from '../../../generated/prisma/enums.js';
import type { AuditLog } from '../audit-log.type.js';

export type AuditLogListItemDto = AuditLog;

export type ListAuditLogsQueryDto = ListPaginationQueryDto<'performedAt'> & {
  entityType?: string;
  actionType?: AuditActionType;
  userId?: string;
  startDate?: string;
  endDate?: string;
};

export type ListAuditLogsResponseDto =
  PaginationResponseDto<AuditLogListItemDto>;
