import { Router } from 'express';

import { requireStoreContext } from './index.js';
import { storeController } from './store.module.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { requirePermission, PERMISSION } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';

const storeRouter = Router();

storeRouter.use(authenticate, requireStoreContext);

storeRouter.get(
  '/',
  requirePermission(PERMISSION.STORE_READ),
  asyncWrapper(storeController.getStores),
);
storeRouter.get(
  '/:storeId',
  requirePermission(PERMISSION.STORE_READ),
  asyncWrapper(storeController.getStoreById),
);
storeRouter.post('/', asyncWrapper(storeController.createStore));
storeRouter.patch(
  '/:storeId',
  requirePermission(PERMISSION.STORE_WRITE),
  asyncWrapper(storeController.updateStore),
);
storeRouter.patch(
  '/:storeId/disable',
  requirePermission(PERMISSION.STORE_WRITE),
  asyncWrapper(storeController.disableStore),
);

export { storeRouter };
