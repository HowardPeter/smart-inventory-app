import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { StoreRepository } from '../repositories/store.repository.js';

import type {
  StoreResponseDto,
  ListStoreResponseDto,
  CreateStoreDto,
  UpdateStoreDto,
} from '../dtos/store.dto.js';

export class StoreService {
  constructor(private readonly storeRepository: StoreRepository) {}

  async getStoresByUserId(userId: string): Promise<ListStoreResponseDto[]> {
    const rawStores = await this.storeRepository.findManybyUserId(userId);

    /*
    Xử lý trả về thêm role của user từ StoreMember clean:
    [
      {
        storeId: '...',
        name: 'Store A',
        role: 'manager'
      }
    ]
    Vì nếu giữ raw query sẽ trả về dạng sau:
    [
      {
        storeId: '...',
        name: 'Store A',
        storeMembers: [
          { role: 'manager' }
        ]
      }
    ]
    */
    return rawStores.map(({ storeMembers, ...store }) => {
      const membership = storeMembers[0];

      if (!membership) {
        throw new CustomError({
          message: 'Store membership not found',
          status: StatusCodes.INTERNAL_SERVER_ERROR,
        });
      }

      return {
        ...store,
        role: membership.role,
      };
    });
  }

  public async getStoreById(
    storeId: string,
    userId: string,
  ): Promise<StoreResponseDto> {
    const store = await this.storeRepository.findByIdAndUserId(storeId, userId);

    if (!store) {
      throw new CustomError({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return store;
  }

  public async createStore(
    userId: string,
    data: CreateStoreDto,
  ): Promise<StoreResponseDto> {
    return await this.storeRepository.createOne({
      ...data,
      userId,
    });
  }

  public async updateStore(
    storeId: string,
    userId: string,
    data: UpdateStoreDto,
  ): Promise<StoreResponseDto> {
    const existingStore = await this.storeRepository.findByIdAndUserId(
      storeId,
      userId,
    );

    if (!existingStore) {
      throw new CustomError({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const updatedStore = await this.storeRepository.updateOne(storeId, data);

    if (!updatedStore) {
      throw new CustomError({
        message: 'Store update failed',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }

    return updatedStore;
  }

  public async disableStore(storeId: string, userId: string): Promise<void> {
    const existingStore = await this.storeRepository.findByIdAndUserId(
      storeId,
      userId,
    );

    if (!existingStore) {
      throw new CustomError({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const isDisabled = await this.storeRepository.disableOne(storeId);

    if (!isDisabled) {
      throw new CustomError({
        message: 'Store disable failed',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }
  }
}
