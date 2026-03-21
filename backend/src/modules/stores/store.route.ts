import { Router } from 'express';

import { requireStoreContext } from './index.js';
import { storeController } from './store.module.js';
import {
  validateCreateStore,
  validateGetStoreById,
  validateDeleteStore,
  validateUpdateStore,
} from './store.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { requirePermission, PERMISSION } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';

const storeRouter = Router();

storeRouter.use(authenticate);

storeRouter
  .route('/')
  .get(asyncWrapper(storeController.getStores))
  .post(validateCreateStore, asyncWrapper(storeController.createStore));

storeRouter
  .route('/:storeId')
  .get(
    requireStoreContext,
    requirePermission(PERMISSION.STORE_READ),
    validateGetStoreById,
    asyncWrapper(storeController.getStoreById),
  )
  .patch(
    requireStoreContext,
    requirePermission(PERMISSION.STORE_WRITE),
    validateUpdateStore,
    asyncWrapper(storeController.updateStore),
  )
  .delete(
    requireStoreContext,
    requirePermission(PERMISSION.STORE_WRITE),
    validateDeleteStore,
    asyncWrapper(storeController.softDeleteStore),
  );

export { storeRouter };
