import { Router } from 'express';

import { storeMemberController } from './store-member.module.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { requirePermission } from '../access-control/require-permission.middleware.js';
import { PERMISSION } from '../access-control/role-permission.constant.js';
import { authenticate } from '../auth/index.js';
import { validate } from '../notification/validators/validate.middleware.js';
import { removeStoreMemberSchema } from '../store-member/store-member.validator.js';
import { requireStoreContext } from '../stores/index.js';

const storeMemberRouter = Router();

/**
 * @api {DELETE} /api/store-members/:userId Xóa thành viên khỏi cửa hàng
 * @description Thực hiện xóa mềm (soft-delete) một người dùng
 * khỏi cửa hàng bằng cách chuyển `activeStatus` thành `inactive`.
 * * @headers
 * - Authorization: Bearer <access_token> (Bắt buộc: Token đăng nhập)
 * - x-store-id: <store_uuid> (Bắt buộc: ID của cửa hàng đang thao tác)
 * * @path_params
 * - userId: string (Bắt buộc: UUID của người bị xóa)
 */

storeMemberRouter.delete(
  '/:userId',
  authenticate,
  requireStoreContext,
  requirePermission(PERMISSION.STORE_MEMBER_DELETE),
  validate(removeStoreMemberSchema),
  asyncWrapper(storeMemberController.removeUser),
);

export { storeMemberRouter };
