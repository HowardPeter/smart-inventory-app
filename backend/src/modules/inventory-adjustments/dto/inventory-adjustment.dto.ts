import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../../common/types/index.js';
import type { InventoryAdjustment } from '../inventory-adjustment.type.js';

// DTO cho 1 item trong danh sách lịch sử
export type InventoryAdjustmentListItemDto = InventoryAdjustment;

// DTO cho Query Params (hỗ trợ phân trang, mặc định sort theo createdAt)
export type ListAdjustmentsQueryDto = ListPaginationQueryDto<'createdAt'>;

// DTO cho Response trả về (bọc trong Pagination)
export type ListAdjustmentsResponseDto =
  PaginationResponseDto<InventoryAdjustmentListItemDto>;
