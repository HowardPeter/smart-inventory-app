import { StatusCodes } from 'http-status-codes';

import { TransactionService } from './transaction.service.js';
import {
  requireReqStoreContext,
  requireReqUser,
  sendResponse,
} from '../../common/utils/index.js';

import type {
  CreateImportTransactionDto,
  CreateImportTransactionResponseDto,
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
      req.body as CreateImportTransactionDto,
    );

    sendResponse.success(res, transaction, {
      status: StatusCodes.CREATED,
    });
  };
}
