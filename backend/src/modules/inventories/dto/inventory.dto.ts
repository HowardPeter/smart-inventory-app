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

export type UpdateInventoryDto = Partial<
  Pick<Inventory, 'reorderThreshold' | 'lastCount'>
>;

export type InventoryAdjustmentDto = {
  type: AdjustmentType;
  quantity: number;
  reason?: string | null;
  note?: string | null;
};

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
