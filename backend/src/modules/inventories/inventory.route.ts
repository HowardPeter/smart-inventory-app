/* Khai báo và cấu hình tập hợp các endpoints (routes) cho module Inventory.
Nhiệm vụ duy nhất của file này là lắp ráp (assemble)
request pipeline theo đúng chuẩn thứ tự:
Authenticate -> Context -> Permission -> Validator -> Controller Handler.
Tuyệt đối không chứa business logic tại đây. */

import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { inventoryController } from '../inventories/inventory.module.js';
import {
  validateAdjustInventory,
  validateCreateInventory,
  validateDeleteInventory,
  validateGetInventories,
  validateGetInventoryByProductPackageId,
  validateGetLowStockInventories,
  validateUpdateInventory,
} from '../inventories/validator/inventory.validator.js';
import { requireStoreContext } from '../stores/index.js';

const inventoryRouter = Router();

// NOTE: Áp dụng middleware xác thực người dùng và
// bắt buộc request phải có ngữ cảnh Store (storeId) cho toàn bộ API bên dưới
inventoryRouter.use(authenticate, requireStoreContext);

// Nhóm API thao tác trên cấp độ toàn danh sách kho của cửa hàng
inventoryRouter.get(
  '/',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetInventories,
  asyncWrapper(inventoryController.getInventories),
);
inventoryRouter.post(
  '/',
  requirePermission(PERMISSION.INVENTORY_WRITE),
  validateCreateInventory,
  asyncWrapper(inventoryController.createInventory),
);

// Endpoint phục vụ nghiệp vụ đặc thù: Truy vấn các mặt hàng
// đang có số lượng chạm hoặc dưới ngưỡng cảnh báo
inventoryRouter.get(
  '/low-stock',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetLowStockInventories,
  asyncWrapper(inventoryController.getLowStockInventories),
);

/* Gom nhóm (chaining) các thao tác CRUD thao tác
trực tiếp trên cấu hình của một mặt hàng cụ thể.
Sử dụng chung tham số đường dẫn (path parameter)
để code DRY (Don't Repeat Yourself). */
inventoryRouter
  .route('/product-packages/:productPackageId')
  .get(
    requirePermission(PERMISSION.INVENTORY_READ),
    validateGetInventoryByProductPackageId,
    asyncWrapper(inventoryController.getInventoryByProductPackageId),
  )
  .patch(
    requirePermission(PERMISSION.INVENTORY_WRITE),
    validateUpdateInventory,
    asyncWrapper(inventoryController.updateInventory),
  )
  .delete(
    // NOTE: Xóa kho thực chất là thao tác xóa mềm
    // (chuyển activeStatus sang inactive) để bảo vệ tính toàn vẹn của AuditLog
    requirePermission(PERMISSION.INVENTORY_WRITE),
    validateDeleteInventory,
    asyncWrapper(inventoryController.deleteInventory),
  );

// Endpoint thực hiện nghiệp vụ cập nhật
// biến động số lượng tồn kho (nhập, xuất, kiểm kê kho)
inventoryRouter.post(
  '/product-packages/:productPackageId/adjustments',
  requirePermission(PERMISSION.INVENTORY_WRITE),
  validateAdjustInventory,
  asyncWrapper(inventoryController.adjustInventory),
);

export { inventoryRouter };
