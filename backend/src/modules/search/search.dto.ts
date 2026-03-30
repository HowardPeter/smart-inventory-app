import type {
  PaginationQuery,
  PaginationResponseDto,
} from '../../common/types/index.js';
import type { BarcodeType, Prisma } from '../../generated/prisma/client.js';
import type { Product } from '../products/index.js';

export type SearchByKeywordQueryDto = PaginationQuery & {
  keyword: string;
};

export type SearchByBarcodeQueryDto = {
  barcode: string;
};

export type SearchByPrefixQueryDto = {
  prefix: string;
  limit?: number;
};

export type SearchProductItemDto = {
  productId: string;
  productName: string;
  imageUrl: string | null;
  brand: string | null;

  categoryId: string;
  categoryName: string;

  productPackageId: string;
  displayName: string | null;
  barcodeValue: string | null;
  barcodeType: BarcodeType | null;
  importPrice: number | null;
  sellingPrice: number | null;

  quantity: number | null;
  reorderThreshold: number | null;

  unitId: string;
  unitCode: string;
  unitName: string;
};

// đại diện cho kết quả trả về từ Prisma
// nên importPrice, sellingPrice cần để Prisma.Decimal
// vì $queryRaw trả về raw result, không tự map kiểu như findMany(),...
export type SearchProductRow = Omit<
  SearchProductItemDto,
  'importPrice' | 'sellingPrice'
> & {
  importPrice: Prisma.Decimal | null;
  sellingPrice: Prisma.Decimal | null;
  rank?: number;
};

export type SearchCountRow = {
  total: bigint;
};

export type ListSearchByKeywordResponseDto =
  PaginationResponseDto<SearchProductItemDto>;

export type SearchProductPrefixResponseDto = Pick<
  Product,
  'productId' | 'name' | 'brand'
>;
