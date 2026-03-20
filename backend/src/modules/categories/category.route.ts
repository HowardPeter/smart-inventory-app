import { Router } from 'express';

import { categoryController } from './category.module.js';
import {
  validateCreateCategory,
  validateUpdateCategory,
} from './category.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

export const categoryRouter = Router();

categoryRouter.use(authenticate, requireStoreContext);

categoryRouter
  .route('/')
  .get(
    requirePermission(PERMISSION.CATEGORY_READ),
    asyncWrapper(categoryController.findAll),
  )
  .post(
    requirePermission(PERMISSION.CATEGORY_WRITE),
    validateCreateCategory,
    asyncWrapper(categoryController.createOne),
  );

categoryRouter
  .route('/:categoryId')
  .patch(
    requirePermission(PERMISSION.CATEGORY_WRITE),
    validateUpdateCategory,
    asyncWrapper(categoryController.updateOne),
  )
  .delete(
    requirePermission(PERMISSION.CATEGORY_WRITE),
    asyncWrapper(categoryController.deleteCustomCategory),
  );

categoryRouter.patch(
  '/:categoryId/hide',
  requirePermission(PERMISSION.CATEGORY_WRITE),
  asyncWrapper(categoryController.softDeleteOne),
);
