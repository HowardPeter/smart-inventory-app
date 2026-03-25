import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { inventoryController } from '../inventories/inventory.module.js';
import {
  validateAdjustInventory,
  validateCreateInventory,
  validateDeleteInventory,
  validateGetInventories,
  validateGetInventoryByProductPackageId,
  validateGetLowStockInventories,
  validateUpdateInventory,
} from '../inventories/validator/inventory.validator.js';
import { requireStoreContext } from '../stores/index.js';

const inventoryRouter = Router();

inventoryRouter.use(authenticate, requireStoreContext);

inventoryRouter.get(
  '/',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetInventories,
  asyncWrapper(inventoryController.getInventories),
);
inventoryRouter.post(
  '/',
  requirePermission(PERMISSION.INVENTORY_WRITE),
  validateCreateInventory,
  asyncWrapper(inventoryController.createInventory),
);

inventoryRouter.get(
  '/low-stock',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetLowStockInventories,
  asyncWrapper(inventoryController.getLowStockInventories),
);

inventoryRouter
  .route('/product-packages/:productPackageId')
  .get(
    requirePermission(PERMISSION.INVENTORY_READ),
    validateGetInventoryByProductPackageId,
    asyncWrapper(inventoryController.getInventoryByProductPackageId),
  )
  .patch(
    requirePermission(PERMISSION.INVENTORY_WRITE),
    validateUpdateInventory,
    asyncWrapper(inventoryController.updateInventory),
  )
  .delete(
    requirePermission(PERMISSION.INVENTORY_WRITE),
    validateDeleteInventory,
    asyncWrapper(inventoryController.deleteInventory),
  );

inventoryRouter.post(
  '/product-packages/:productPackageId/adjustments',
  requirePermission(PERMISSION.INVENTORY_WRITE),
  validateAdjustInventory,
  asyncWrapper(inventoryController.adjustInventory),
);

export { inventoryRouter };
