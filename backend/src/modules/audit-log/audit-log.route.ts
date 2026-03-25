/* Khai báo và cấu hình các endpoints (routes) cho module Audit Log.
Nhiệm vụ duy nhất của file này là lắp ráp
(assemble) request pipeline theo thứ tự:
Authenticate -> Context -> Permission -> Validator -> Controller Handler.
Tuyệt đối không chứa business logic tại đây. */

import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { auditLogController } from '../audit-log/audit-log.module.js';
import { validateGetAuditLogs } from '../audit-log/validator/audit-log.validator.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const auditLogRouter = Router();

// NOTE: Áp dụng middleware xác thực và bắt buộc có ngữ cảnh cửa hàng
// (storeId) cho toàn bộ API để đảm bảo tính cô lập dữ liệu
auditLogRouter.use(authenticate, requireStoreContext);

auditLogRouter.get(
  '/',
  requirePermission(PERMISSION.AUDIT_LOG_READ),
  validateGetAuditLogs,
  asyncWrapper(auditLogController.getAuditLogs),
);

export { auditLogRouter };
