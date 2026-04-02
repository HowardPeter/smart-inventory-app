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
 *  khỏi cửa hàng bằng cách chuyển `activeStatus` thành `inactive`.
 * * @headers
 * - Authorization: Bearer <access_token>
 * (Bắt buộc: Token đăng nhập của người đang thao tác)
 * - x-store-id: <store_uuid>
 * (Bắt buộc: Truyền ID của cửa hàng đang thao tác)
 * * @path_params
 * - userId: string (UUID)               (Bắt buộc: ID của người bị xóa)
 * * @business_rules (Frontend lưu ý để ẩn/hiện nút Xóa trên UI)
 * 1. OWNER (Chủ cửa hàng) có thể xóa MANAGER và STAFF.
 * 2. MANAGER (Quản lý) chỉ có thể xóa STAFF. (Không thể xóa MANAGER khác).
 * 3. Không ai có thể xóa OWNER.
 * 4. Không thể tự xóa chính mình qua API này.
 * * @success_response 200 OK
 * Trả về ApiResponse chuẩn. Dữ liệu (data) là thông tin của
 * StoreMember vừa bị xóa (có activeStatus: 'inactive').
 * * @error_responses
 * - 400 Bad Request: `userId` sai định dạng UUID,
 * tự xóa chính mình, hoặc user đã bị xóa từ trước.
 * - 401 Unauthorized: Thiếu token hoặc token không hợp lệ.
 * - 403 Forbidden:
 * + Người gọi không có quyền STORE_MEMBER_DELETE (VD: Staff gọi API).
 * + Vi phạm phân cấp (VD: Manager cố xóa Manager khác).
 * + Cố tình xóa Chủ cửa hàng (Owner).
 * - 404 Not Found: `userId` không tồn tại trong
 * danh sách thành viên của cửa hàng này.
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
