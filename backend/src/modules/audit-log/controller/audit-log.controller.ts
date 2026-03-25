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

/* Controller xử lý các request liên quan đến lịch sử hệ thống (Audit Log).
Chịu trách nhiệm tiếp nhận truy vấn kiểm toán, lịch sử thay đổi dữ liệu
và trả về kết quả theo chuẩn format của dự án. */
export class AuditLogController {
  constructor(private readonly auditLogService: AuditLogService) {}

  getAuditLogs = async (
    req: Request,
    res: Response<ApiResponse<ListAuditLogsResponseDto>>,
  ): Promise<void> => {
    // NOTE: Bắt buộc lấy storeId từ context để đảm bảo
    // người dùng chỉ xem được log của cửa hàng họ đang thao tác
    const storeId = requireReqStoreContext(req).storeId;

    const logs = await this.auditLogService.getAuditLogs(
      storeId,
      res.locals.validatedQuery as unknown as ListAuditLogsQueryDto,
    );

    sendResponse.success(res, logs, { status: StatusCodes.OK });
  };
}
