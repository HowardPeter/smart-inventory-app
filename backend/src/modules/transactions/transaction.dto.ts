import type { Transaction, TransactionDetail } from './transaction.type.js';
import type { Prisma } from '../../generated/prisma/client.js';
import type { ProductPackageResponseForTransaction } from '../product-packages/index.js';

export type ProductPackageData = ProductPackageResponseForTransaction;

export type TransactionResponseDto = Omit<Transaction, 'userId' | 'storeId'>;

export type TransactionDetailResponseDto = TransactionDetail;

export type CreateTransactionDetailData = {
  transactionId: string;
  items: {
    productPackageId: string;
    quantity: number;
    unitPrice: Prisma.Decimal;
  }[];
};

export type CreateTransactionData = {
  type: 'import' | 'export';
  note?: string | null;
  totalPrice: number;
  userId: string;
  storeId: string;
};

export type CreateTransactionItemDto = Omit<TransactionDetail, 'transactionId'>;

export type CreateTransactionDto = {
  note?: string | null;
  items: CreateTransactionItemDto[];
};

// Thay đổi về giá package để hỏi user xác nhận cập nhật price cho package
export type PriceUpdateSuggestionDto = {
  productPackageId: string;
  currentImportPrice: number | null;
  latestImportUnitPrice: number;
};

type CreateTransactionResultDto = Omit<Transaction, 'userId' | 'storeId'> & {
  items: CreateTransactionItemDto[];
};

export type CreateImportTransactionResponseDto = CreateTransactionResultDto & {
  priceUpdateSuggestions: PriceUpdateSuggestionDto[];
};

export type CreateExportTransactionResponseDto = CreateTransactionResultDto;
