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
} from './transaction.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class TransactionController {
  constructor(private readonly transactionService: TransactionService) {}

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
