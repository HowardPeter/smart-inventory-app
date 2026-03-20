import { Router } from 'express';

import { productController } from './product.module.js';
import {
  validateGetProducts,
  validateCreateProduct,
  validateDeleteProduct,
  validateGetProductById,
  validateUpdateProduct,
} from './product.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const productRouter = Router();

productRouter.use(authenticate, requireStoreContext);

productRouter
  .route('/')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProducts,
    asyncWrapper(productController.getProducts),
  )
  .post(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateCreateProduct,
    asyncWrapper(productController.createProduct),
  );

productRouter
  .route('/:productId')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProductById,
    asyncWrapper(productController.getProductById),
  )
  .patch(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateUpdateProduct,
    asyncWrapper(productController.updateProduct),
  )
  .delete(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateDeleteProduct,
    asyncWrapper(productController.softDeleteProduct),
  );

export { productRouter };
