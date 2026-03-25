import { InventoryAdjustmentController } from '../inventory-adjustments/controller/inventory-adjustment.controller.js';
import { InventoryAdjustmentRepository } from '../inventory-adjustments/repository/inventory-adjustment.repository.js';
import { InventoryAdjustmentService } from '../inventory-adjustments/service/inventory-adjustment.service.js';

const inventoryAdjustmentRepository = new InventoryAdjustmentRepository();
const inventoryAdjustmentService = new InventoryAdjustmentService(
  inventoryAdjustmentRepository,
);

export const inventoryAdjustmentController = new InventoryAdjustmentController(
  inventoryAdjustmentService,
);
