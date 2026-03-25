import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { inventoryAdjustmentController } from '../inventory-adjustments/inventory-adjustment.module.js';
import { validateGetAdjustments } from '../inventory-adjustments/validator/inventory-adjustment.validator.js';
import { requireStoreContext } from '../stores/index.js';

const inventoryAdjustmentRouter = Router();

inventoryAdjustmentRouter.use(authenticate, requireStoreContext);

// Giữ URL này để tương đồng với logic cũ, nhưng nó được handle bởi module mới
inventoryAdjustmentRouter.get(
  '/product-packages/:productPackageId',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetAdjustments,
  asyncWrapper(inventoryAdjustmentController.getAdjustments),
);

export { inventoryAdjustmentRouter };
