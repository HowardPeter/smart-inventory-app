import { StatusCodes } from 'http-status-codes';

import { TransactionService } from './transaction.service.js';
import {
  requireReqStoreContext,
  requireReqUser,
  sendResponse,
} from '../../common/utils/index.js';

import type {
  CreateTransactionDto,
  CreateImportTransactionResponseDto,
  CreateExportTransactionResponseDto,
  ListTransactionsResponseDto,
  ListTransactionsQueryDto,
  DetailTransactionResponseDto,
} from './transaction.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class TransactionController {
  constructor(private readonly transactionService: TransactionService) {}

  getTransactions = async (
    req: Request,
    res: Response<ApiResponse<ListTransactionsResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const transactions = await this.transactionService.getTransactionsByStoreId(
      storeId,
      res.locals.validatedQuery as unknown as ListTransactionsQueryDto,
    );

    sendResponse.success(res, transactions, {
      status: StatusCodes.OK,
    });
  };

  getTransactionById = async (
    req: Request,
    res: Response<ApiResponse<DetailTransactionResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { transactionId } = req.params;

    const transaction = await this.transactionService.getTransactionById(
      storeId,
      transactionId as string,
    );

    sendResponse.success(res, transaction, {
      status: StatusCodes.OK,
    });
  };

  createImportTransaction = async (
    req: Request,
    res: Response<ApiResponse<CreateImportTransactionResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;

    const transaction = await this.transactionService.createImportTransaction(
      storeId,
      userId,
      req.body as CreateTransactionDto,
    );

    sendResponse.success(res, transaction, {
      status: StatusCodes.CREATED,
    });
  };

  createExportTransaction = async (
    req: Request,
    res: Response<ApiResponse<CreateExportTransactionResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;

    const transaction = await this.transactionService.createExportTransaction(
      storeId,
      userId,
      req.body as CreateTransactionDto,
    );

    sendResponse.success(res, transaction, {
      status: StatusCodes.CREATED,
    });
  };
}
