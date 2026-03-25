import { AuditLogController } from '../audit-log/controller/audit-log.controller.js';
import { AuditLogRepository } from '../audit-log/repository/audit-log.repository.js';
import { AuditLogService } from '../audit-log/service/audit-log.service.js';

const auditLogRepository = new AuditLogRepository();
const auditLogService = new AuditLogService(auditLogRepository);

export const auditLogController = new AuditLogController(auditLogService);
