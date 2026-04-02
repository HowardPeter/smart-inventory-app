import type { Transaction, TransactionDetail } from './transaction.type.js';
import type { Prisma } from '../../generated/prisma/client.js';

export type ImportTransactionResponseDto = Omit<
  Transaction,
  'userId' | 'storeId'
>;

export type TransactionDetailResponseDto = TransactionDetail;

export type CreateTransactionDetailData = {
  transactionId: string;
  items: {
    productPackageId: string;
    quantity: number;
    unitPrice: Prisma.Decimal;
  }[];
};

export type CreateImportTransactionData = {
  note?: string | null;
  totalPrice: number;
  userId: string;
  storeId: string;
};

export type CreateImportTransactionItemDto = Omit<
  TransactionDetail,
  'transactionId'
> & {
  productId: string;
};

export type CreateImportTransactionDto = {
  note?: string | null;
  items: CreateImportTransactionItemDto[];
};

// Thay đổi về giá package để hỏi user xác nhận cập nhật price cho package
export type PriceUpdateSuggestionDto = {
  productPackageId: string;
  currentImportPrice: number | null;
  latestImportUnitPrice: number;
};

export type CreateImportTransactionResultDto = Omit<
  Transaction,
  'userId' | 'storeId'
> & {
  items: CreateImportTransactionItemDto[];
};

export type CreateImportTransactionResponseDto =
  CreateImportTransactionResultDto & {
    priceUpdateSuggestions: PriceUpdateSuggestionDto[];
  };
