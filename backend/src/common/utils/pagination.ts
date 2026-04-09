import { Prisma } from '../../generated/prisma/client.js';

import type { PaginationMeta, PaginationQuery } from '../types/index.js';

type PaginationParams = Required<PaginationQuery>;

type NormalizePaginationOptions = {
  defaultPage?: number;
  defaultLimit?: number;
  maxLimit?: number;
};

/* Chuẩn hóa đầu vào query của pagination
tránh client gửi input rác, ví dụ: page: "abc", limit: 99999 */
export const normalizePagination = (
  query: PaginationQuery,
  options?: NormalizePaginationOptions,
): PaginationParams => {
  // INFO: '??': nếu giá trị bên trái là null/undefine thì lấy giá trị bên phải
  // gán giá trị mặc định cho page, limit, max limit
  const defaultPage = options?.defaultPage ?? 1;
  const defaultLimit = options?.defaultLimit ?? 10;
  const maxLimit = options?.maxLimit ?? 100;

  // gán giá trị cho page và limit nhưng chưa chuẩn hóa
  const rawPage = query.page ?? defaultPage;
  const rawLimit = query.limit ?? defaultLimit;

  /* nếu rawPage không phải number (isNaN) or < 1 thì gán page = defaultPage
  nếu không thì bỏ số thập phân của rawPage (nếu có) bằng Math.floor */
  const page =
    Number.isNaN(rawPage) || rawPage < 1 ? defaultPage : Math.floor(rawPage);

  // tương tự như page
  const limit =
    Number.isNaN(rawLimit) || rawLimit < 1
      ? defaultLimit
      : Math.min(Math.floor(rawLimit), maxLimit); // lấy giá trị nhỏ hơn

  return {
    page,
    limit,
  };
};

// tính skip khi paginate
export const getPaginationSkip = ({
  page,
  limit,
}: PaginationParams): number => {
  return (page - 1) * limit;
};

// tạo metadata trả về cho hàm service
const buildPaginationMeta = (
  totalItems: number,
  query: PaginationQuery,
): PaginationMeta => {
  const { page, limit } = normalizePagination(query);

  return {
    page,
    limit,
    totalItems,
    totalPages: totalItems > 0 ? Math.ceil(totalItems / limit) : 0,
  };
};

// gộp return {item, metadata} trong hàm service
export const buildPaginatedResponse = <T>(
  items: T[],
  totalItems: number,
  query: PaginationQuery,
): {
  items: T[];
  meta: PaginationMeta;
} => {
  return {
    items,
    meta: buildPaginationMeta(totalItems, query),
  };
};

export const dateRangeFilter = (
  startDate?: Date,
  endDate?: Date,
): Prisma.DateTimeFilter | undefined => {
  if (!startDate && !endDate) {
    return undefined;
  }

  const filter: Prisma.DateTimeFilter = {};

  if (startDate) {
    filter.gte = startDate;
  }

  if (endDate) {
    // lấy tới cuối ngày
    filter.lte = new Date(
      new Date(endDate).setHours(23, 59, 59, 999),
    );
  }

  return filter;
};
