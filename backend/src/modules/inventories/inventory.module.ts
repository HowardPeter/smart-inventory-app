/* Xử lý Dependency Injection (DI) cho module Inventory.
Khởi tạo và liên kết (wiring) các lớp Repository,
Service và Controller với nhau.
Các module hoặc route khác sẽ import
controller/service từ file này để sử dụng. */

import { prisma } from '../../db/prismaClient.js';
import { InventoryController } from '../inventories/controller/inventory.controller.js';
import { InventoryRepository } from '../inventories/repository/inventory.repository.js';
import { InventoryService } from '../inventories/service/inventory.service.js';

const inventoryRepository = new InventoryRepository(prisma);
const inventoryService = new InventoryService(inventoryRepository);

export const inventoryController = new InventoryController(inventoryService);
