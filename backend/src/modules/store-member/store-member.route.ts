import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { requirePermission } from '../access-control/require-permission.middleware.js';
import { PERMISSION } from '../access-control/role-permission.constant.js';
import { authenticate } from '../auth/index.js';
import { validate } from '../notification/validators/validate.middleware.js';
import { removeStoreMemberSchema } from '../store-member/store-member.validator.js';
import { storeMemberController } from '../store-member/store.module.js';
import { requireStoreContext } from '../stores/index.js';

const storeMemberRouter = Router();

// Endpoint xóa (soft-delete) user khỏi store
storeMemberRouter.delete(
  '/:userId',
  authenticate,
  requireStoreContext,
  requirePermission(PERMISSION.STORE_MEMBER_READ),
  // Đảm bảo người dùng có quyền xoá
  validate(removeStoreMemberSchema),
  asyncWrapper(storeMemberController.removeUser),
);

export { storeMemberRouter };
