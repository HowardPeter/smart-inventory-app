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

productRouter.get(
  '/',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetProducts,
  asyncWrapper(productController.getProducts),
);

productRouter.get(
  '/:productId',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetProductById,
  asyncWrapper(productController.getProductById),
);

productRouter.post(
  '/',
  requirePermission(PERMISSION.PRODUCT_WRITE),
  validateCreateProduct,
  asyncWrapper(productController.createProduct),
);

productRouter.patch(
  '/:productId',
  requirePermission(PERMISSION.PRODUCT_WRITE),
  validateUpdateProduct,
  asyncWrapper(productController.updateProduct),
);

productRouter.delete(
  '/:productId',
  requirePermission(PERMISSION.PRODUCT_WRITE),
  validateDeleteProduct,
  asyncWrapper(productController.softDeleteProduct),
);

export { productRouter };
