/* Định nghĩa các Data Transfer Object (DTO) cho module Inventory.
Bao gồm các contract quy định cấu trúc dữ liệu input/output của API.
Các DTO được dẫn xuất từ type gốc để đảm bảo đồng bộ với schema Database. */

import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../../common/types/index.js';
import type {
  AdjustmentType,
  Inventory,
  InventoryStatus,
  ProductPackageSnapshot,
  ProductSnapshot,
  Unit,
} from '../inventory.type.js';

export type InventoryResponseDto = Inventory;

// NOTE: Lược bỏ productPackageId gốc để flatten
// (làm phẳng) dữ liệu,
// thay thế bằng object chứa chi tiết thông tin hiển thị
// của sản phẩm và quy cách đóng gói
export type InventoryListItemDto = Omit<Inventory, 'productPackageId'> & {
  inventoryStatus: InventoryStatus;
  productPackage: ProductPackageSnapshot & {
    unit: Unit;
    product: ProductSnapshot;
  };
};

export type InventoryDetailResponseDto = InventoryListItemDto;

export type InventorySortBy =
  | 'updatedAt'
  | 'quantity'
  | 'reorderThreshold'
  | 'lastCount';

// DTO quy định các tham số query trên URL cho API lấy danh sách tồn kho
export type ListInventoriesQueryDto =
  ListPaginationQueryDto<InventorySortBy> & {
    keyword?: string;
    categoryId?: string;
    inventoryStatus?: InventoryStatus;
  };

export type ListInventoriesResponseDto =
  PaginationResponseDto<InventoryListItemDto>;

export type LowStockInventoriesResponseDto =
  PaginationResponseDto<InventoryListItemDto>;

// Theo business rule, API update thông thường chỉ
// cho phép sửa cấu hình cảnh báo hoặc số lần kiểm kê.
// Tuyệt đối không chứa field 'quantity'
// ở đây để tránh việc sửa số lượng mà không ghi log.
export type UpdateInventoryDto = Partial<
  Pick<Inventory, 'reorderThreshold' | 'lastCount'>
>;

// DTO dành riêng cho nghiệp vụ
// điều chỉnh số lượng tồn kho (nhập, xuất, cân bằng)
export type InventoryAdjustmentDto = {
  type: AdjustmentType;
  quantity: number;
  reason?: string | null;
  note?: string | null;
};

// Contract trả về kết quả sau khi điều chỉnh kho,
// tính toán sẵn số lượng chênh lệch (changedQuantity)
export type InventoryAdjustmentResponseDto = {
  productPackageId: string;
  previousQuantity: number;
  currentQuantity: number;
  changedQuantity: number;
  adjustmentType: AdjustmentType;
  reason: string | null;
  note: string | null;
  updatedAt: Date;
};

export type CreateInventoryDto = {
  productPackageId: string;
  quantity: number;
  reorderThreshold?: number | null;
  lastCount?: number | null;
};

export type AdjustInventoryForTransactionDto = Pick<
  Inventory,
  'inventoryId' | 'productPackageId' | 'quantity'
> & {
  transactionQuantity: number;
  unitPrice: number;
  transactionId: string;
};

export type InventoryForTransactionData = Pick<
  Inventory,
  'productPackageId' | 'quantity'
> & {
  transactionId: string;
  unitPrice: number;
};
