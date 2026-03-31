import { Router } from 'express';

import { productPackageController } from './product-package.module.js';
import {
  validateCreateProductPackage,
  validateDeleteProductPackage,
  validateGetProductPackageById,
  validateGetProductPackagesByProductId,
  validateUpdateProductPackage,
  validateGetPackagesByStore,
} from './product-package.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const productPackageRouter = Router();
const productPackageProductRouter = Router();

productPackageRouter.use(authenticate, requireStoreContext);
productPackageProductRouter.use(authenticate, requireStoreContext);

productPackageRouter.get(
  '/',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetPackagesByStore,
  asyncWrapper(productPackageController.getProductPackagesByStore),
);

productPackageProductRouter
  .route('/:productId/packages')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProductPackagesByProductId,
    asyncWrapper(productPackageController.getProductPackagesByProductId),
  )
  .post(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateCreateProductPackage,
    asyncWrapper(productPackageController.createProductPackage),
  );

productPackageRouter
  .route('/:productPackageId')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProductPackageById,
    asyncWrapper(productPackageController.getProductPackageById),
  )
  .patch(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateUpdateProductPackage,
    asyncWrapper(productPackageController.updateProductPackage),
  )
  .delete(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateDeleteProductPackage,
    asyncWrapper(productPackageController.softDeleteProductPackage),
  );

export { productPackageRouter, productPackageProductRouter };
