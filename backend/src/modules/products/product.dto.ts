import type { Product } from './product.type.js';
import type { PaginationMeta, PaginationQuery } from '../../common/types/index.js';
import type { Category } from '../categories/categoty.type.js';

export type ProductResponseDto = Product;

export type DetailProductResponseDto = Omit<Product, 'categoryId'> & {
  category: Omit<Category, 'storeId' | 'isDefault'>;
};

export type CreateProductDto = Pick<Product, 'name' | 'categoryId'> & {
  imageUrl?: string | null;
  brand?: string | null;
};

export type CreateProductData = CreateProductDto & {
  storeId: string;
};

export type UpdateProductDto = Partial<
  Pick<Product, 'brand' | 'imageUrl' | 'name' | 'categoryId'>
>;

export type ProductSortBy = 'name' | 'createdAt' | 'updatedAt';
export type SortOrder = 'asc' | 'desc';

export type ListProductsQueryDto = PaginationQuery & {
  sortBy?: ProductSortBy;
  sortOrder?: SortOrder;
} & Partial<Pick<Product, 'categoryId' | 'brand'>>;

export type ProductListItemDto = DetailProductResponseDto;

export type ListProductsResponseDto = {
  items: ProductListItemDto[];
  meta: PaginationMeta;
};

