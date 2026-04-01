export interface PaginationQuery {
  page?: number;
  limit?: number;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  totalItems: number;
  totalPages: number;
}

export type SortOrder = 'asc' | 'desc';

/* dto dùng ghép các dto của query pagination trong các module
vd:
export type ListProductsQueryDto = ListPaginationQueryDto<ProductSortBy> &
  Partial<Pick<Product, 'categoryId' | 'brand'>>;
--> ListProductsQueryDto = {
      page?: number;
      limit?: number;
      sortBy?: ProductSortBy;
      sortOrder?: SortOrder;
      categoryId?: string;
      brand?: string;
    }
*/
export type ListPaginationQueryDto<T> = PaginationQuery & {
  sortBy?: T;
  sortOrder?: SortOrder;
};

// Dto cho kiểu trả về các hàm repository có pagination
export type ListPaginationResponseDto<T> = {
  items: T[];
  totalItems: number;
};

// dto dùng chung để in response các hàm service có pagination
export type PaginationResponseDto<T> = {
  items: T[];
  meta: PaginationMeta;
};
