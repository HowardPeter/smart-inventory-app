import { Router } from 'express';

import { requireStoreContext } from './index.js';
import { storeController } from './store.module.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { requirePermission, PERMISSION } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';

const storeRouter = Router();

storeRouter.use(authenticate);

storeRouter.get('/', asyncWrapper(storeController.getStores));

storeRouter.get(
  '/:storeId',
  requireStoreContext,
  requirePermission(PERMISSION.STORE_READ),
  asyncWrapper(storeController.getStoreById),
);

storeRouter.post('/', asyncWrapper(storeController.createStore));

storeRouter.patch(
  '/:storeId',
  requireStoreContext,
  requirePermission(PERMISSION.STORE_WRITE),
  asyncWrapper(storeController.updateStore),
);

storeRouter.patch(
  '/:storeId/disable',
  requireStoreContext,
  requirePermission(PERMISSION.STORE_WRITE),
  asyncWrapper(storeController.disableStore),
);

export { storeRouter };
