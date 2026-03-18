import { prisma } from '../../../db/prismaClient.js';

import type {
  StoreResponseDto,
  CreateStoreDto,
  UpdateStoreDto,
  ListRawStoreDto,
} from '../dtos/store.dto.js';

export class StoreRepository {
  async findManybyUserId(userId: string): Promise<ListRawStoreDto[]> {
    return await prisma.store.findMany({
      where: {
        activeStatus: 'active',
        storeMembers: {
          some: {
            userId,
            activeStatus: 'active',
          },
        },
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        storeMembers: {
          where: {
            userId,
            activeStatus: 'active',
          },
          select: {
            role: true,
          },
        },
      },
    });
  }

  async findById(storeId: string): Promise<StoreResponseDto | null> {
    return await prisma.store.findFirst({
      where: {
        storeId: storeId,
        activeStatus: 'active',
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
      },
    });
  }

  async findByIdAndUserId(
    storeId: string,
    userId: string,
  ): Promise<StoreResponseDto | null> {
    return await prisma.store.findFirst({
      where: {
        storeId,
        activeStatus: 'active',
        storeMembers: {
          some: {
            userId,
            activeStatus: 'active',
          },
        },
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
      },
    });
  }

  async createOne(data: CreateStoreDto): Promise<StoreResponseDto> {
    return await prisma.store.create({
      data,
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
      },
    });
  }

  async updateOne(
    storeId: string,
    data: UpdateStoreDto,
  ): Promise<StoreResponseDto | null> {
    return await prisma.store.update({
      where: { storeId },
      data,
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
      },
    });
  }

  async disableOne(storeId: string): Promise<boolean> {
    const disableStore = await prisma.store.update({
      where: { storeId: storeId },
      data: {
        activeStatus: 'inactive',
      },
    });

    return disableStore !== null ? true : false;
  }
}
