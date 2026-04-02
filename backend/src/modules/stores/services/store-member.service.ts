import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';

import type { StoreRole } from '../../../generated/prisma/enums.js';
import type { StoreMembershipResponseDto } from '../dtos/store-member.dto.js';
import type { StoreMemberRepository } from '../repositories/store-member.repository.js';

export class StoreMemberService {
  constructor(private readonly storeMemberRepository: StoreMemberRepository) {}

  async getMembershipByUserIdAndStoreId(
    userId: string,
    storeId: string,
  ): Promise<StoreMembershipResponseDto | null> {
    if (!userId || !storeId) {
      throw new CustomError({
        message:
          'User ID and Store ID are required to fetch membership information',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const membership =
      await this.storeMemberRepository.findOneByUserIdAndStoreId(
        userId,
        storeId,
      );

    if (!membership) {
      return null;
    }

    return membership;
  }

  async createNewMembership(
    userId: string,
    storeId: string,
    role: StoreRole,
  ): Promise<StoreMembershipResponseDto> {
    if (!userId || !storeId) {
      throw new CustomError({
        message:
          'User ID and Store ID are required to fetch membership information',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    return await this.storeMemberRepository.createOne({
      userId,
      storeId,
      role,
    });
  }
}
