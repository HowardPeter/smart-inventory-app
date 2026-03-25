import { InventoryController } from '../inventories/controller/inventory.controller.js';
import { InventoryRepository } from '../inventories/repository/inventory.repository.js';
import { InventoryService } from '../inventories/service/inventory.service.js';

const inventoryRepository = new InventoryRepository();
const inventoryService = new InventoryService(inventoryRepository);

export const inventoryController = new InventoryController(inventoryService);
