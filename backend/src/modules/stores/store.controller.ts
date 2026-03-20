import { StatusCodes } from 'http-status-codes';

import { StoreService } from './services/store.service.js';
import { requireReqUser, sendResponse } from '../../common/utils/index.js';

import type { StoreResponseDto } from './dtos/store.dto.js';
import type { CreateStoreDto, UpdateStoreDto } from './dtos/store.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class StoreController {
  constructor(private readonly storeService: StoreService) {}

  getStores = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto[]>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const stores = await this.storeService.getStoresByUserId(userId);

    sendResponse.success(res, stores, { status: StatusCodes.OK });
  };

  getStoreById = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const { storeId } = req.params;

    const store = await this.storeService.getStoreById(
      storeId as string,
      userId,
    );

    sendResponse.success(res, store, { status: StatusCodes.OK });
  };

  createStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const payload = req.body as CreateStoreDto;

    const createdStore = await this.storeService.createStore(userId, payload);

    sendResponse.success(res, createdStore, { status: StatusCodes.CREATED });
  };

  updateStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const { storeId } = req.params;
    const payload = req.body as UpdateStoreDto;

    const updatedStore = await this.storeService.updateStore(
      storeId as string,
      userId,
      payload,
    );

    sendResponse.success(res, updatedStore, { status: StatusCodes.OK });
  };

  disableStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const { storeId } = req.params;

    await this.storeService.disableStore(storeId as string, userId);

    sendResponse.success(res, null, { status: StatusCodes.OK });
  };
}
