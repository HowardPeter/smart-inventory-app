/* Xử lý Dependency Injection (DI) cho module Inventory.
Khởi tạo và liên kết (wiring) các lớp Repository,
Service và Controller với nhau.
Các module hoặc route khác sẽ import
controller/service từ file này để sử dụng. */

import { prisma } from '../../db/prismaClient.js';
import { AuditLogRepository } from '../audit-log/repository/audit-log.repository.js';
import { InventoryController } from '../inventories/controller/inventory.controller.js';
import { InventoryRepository } from '../inventories/repository/inventory.repository.js';
import { InventoryService } from '../inventories/service/inventory.service.js';

const auditLogRepository = new AuditLogRepository(prisma);
const inventoryRepository = new InventoryRepository(prisma);
const inventoryService = new InventoryService(
  inventoryRepository,
  auditLogRepository,
);
const inventoryController = new InventoryController(inventoryService);

export { inventoryService, inventoryController };
