import { z } from 'zod';

import type { ProductPackage, Unit } from './product-package.type.js';
import type { listPackageQuerySchema } from './product-package.validator.js';
import type { PaginationResponseDto } from '../../common/types/pagination.type.js';
import type { Category } from '../categories/index.js';
import type { CreateInventoryDto, Inventory } from '../inventories/index.js';
import type { Product } from '../products/index.js';

export type UnitResponseDto = Unit;

export type ProductPackageResponseDto = Omit<
  ProductPackage,
  'unitId' | 'productId'
> & {
  unit: Unit;
  category: Pick<Category, 'categoryId' | 'name'>;
  product: Pick<Product, 'productId' | 'name' | 'storeId'>;
  inventory: Pick<
    Inventory,
    'inventoryId' | 'quantity' | 'reorderThreshold'
  > | null;
};

export type ProductPackageResponseForTransaction = Pick<
  ProductPackage,
  'productPackageId' | 'displayName' | 'importPrice' | 'sellingPrice'
>;

export type CreateProductPackageDto = Pick<ProductPackage, 'unitId'> &
  Partial<
    Pick<
      ProductPackage,
      'importPrice' | 'sellingPrice' | 'barcodeValue' | 'barcodeType'
    >
  >;

export type CreateProductPackageData = CreateProductPackageDto & {
  productId: string;
  displayName: string;
};

export type CreateInventoryData = Pick<
  CreateInventoryDto,
  'quantity' | 'reorderThreshold'
>;

export type CreateProductPackageAndInventoryDto = {
  package: CreateProductPackageDto;
  inventory: CreateInventoryDto;
};

export type UpdateProductPackageDto = Partial<
  Pick<
    ProductPackage,
    | 'displayName'
    | 'importPrice'
    | 'sellingPrice'
    | 'barcodeValue'
    | 'barcodeType'
  >
>;

/* Thừa kế type dựa trên schema Zod listPackageQuerySchema
Kết quả:
type PackageQueryDto = {
  page: number;
  limit: number;
  sortBy: 'displayName' | 'createdAt' | 'updatedAt';
  sortOrder: 'asc' | 'desc';
  categoryId?: string;
}; */
export type PackageQueryDto = z.infer<typeof listPackageQuerySchema>;

export type ListProductPackagesResponseDto =
  PaginationResponseDto<ProductPackageResponseDto>;
