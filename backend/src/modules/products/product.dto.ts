import type { Product } from './product.type.js';
import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../common/types/index.js';
import type { Category } from '../categories/index.js';

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

export type ListProductsQueryDto = ListPaginationQueryDto<ProductSortBy> &
  Partial<Pick<Product, 'categoryId' | 'brand'>>;

export type ProductListItemDto = DetailProductResponseDto;

export type ListProductsResponseDto = PaginationResponseDto<ProductListItemDto>;
