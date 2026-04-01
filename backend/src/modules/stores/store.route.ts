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

/**
 * API endpoint: GET /api/stores
 * Lấy danh sách cửa hàng mà user hiện tại đang tham gia
 *
 * API endpoint: POST /api/stores
 * Tạo cửa hàng mới
 *
 * Body:
 *  - name: string (required) - tên cửa hàng
 *  - address?: string | null - địa chỉ cửa hàng
 *  - timezone?: string | null - múi giờ của cửa hàng
 */
storeRouter
  .route('/')
  .get(asyncWrapper(storeController.getStores))
  .post(validateCreateStore, asyncWrapper(storeController.createStore));

/**
 * API endpoint: GET /api/stores/:storeId
 * Lấy chi tiết một cửa hàng theo id
 *
 * Path params:
 *  - storeId: string (UUID, required)
 *
 * API endpoint: PATCH /api/stores/:storeId
 * Cập nhật thông tin cửa hàng
 *
 * Path params:
 *  - storeId: string (UUID, required)
 *
 * Body:
 *  - name?: string - tên cửa hàng
 *  - address?: string | null - địa chỉ cửa hàng
 *  - timezone?: string | null - múi giờ của cửa hàng
 *
 * API endpoint: DELETE /api/stores/:storeId
 * Xóa mềm cửa hàng theo id
 *
 * Path params:
 *  - storeId: string (UUID, required)
 */
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
