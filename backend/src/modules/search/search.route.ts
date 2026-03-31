import { Router } from 'express';

import { searchController } from './search.module.js';
import {
  validateGetProductsByKeyword,
  validateGetProductsByPrefix,
} from './search.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const searchRouter = Router();

searchRouter.use(authenticate, requireStoreContext);

searchRouter.get(
  '/products',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetProductsByKeyword,
  asyncWrapper(searchController.getProductsbyKeyword),
);

searchRouter.get(
  '/product-packages',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetProductsByKeyword,
  asyncWrapper(searchController.getProductPackagesbyKeyword),
);

searchRouter.get(
  '/products/prefix',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetProductsByPrefix,
  asyncWrapper(searchController.getProductsByPrefix),
);

export { searchRouter };
