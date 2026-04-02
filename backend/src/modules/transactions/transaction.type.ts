import {
  TransactionStatus,
  TransactionType,
} from '../../generated/prisma/enums.js';

export type Transaction = {
  transactionId: string;
  type: TransactionType;
  note: string | null;
  status: TransactionStatus;
  createdAt: Date;
  totalPrice: number;
  userId: string;
  storeId: string;
};

export type TransactionDetail = {
  quantity: number;
  unitPrice: number;
  transactionId: string;
  productPackageId: string;
};
