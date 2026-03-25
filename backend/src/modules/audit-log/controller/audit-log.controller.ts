import { StatusCodes } from 'http-status-codes';

import {
  requireReqStoreContext,
  sendResponse,
} from '../../../common/utils/index.js';
import { AuditLogService } from '../service/audit-log.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  ListAuditLogsQueryDto,
  ListAuditLogsResponseDto,
} from '../dto/audit-log.dto.js';
import type { Request, Response } from 'express';

export class AuditLogController {
  constructor(private readonly auditLogService: AuditLogService) {}

  getAuditLogs = async (
    req: Request,
    res: Response<ApiResponse<ListAuditLogsResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const logs = await this.auditLogService.getAuditLogs(
      storeId,
      res.locals.validatedQuery as unknown as ListAuditLogsQueryDto,
    );

    sendResponse.success(res, logs, { status: StatusCodes.OK });
  };
}
