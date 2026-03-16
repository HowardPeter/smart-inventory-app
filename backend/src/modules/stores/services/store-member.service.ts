import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';

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
      await this.storeMemberRepository.findMembershipByUserIdAndStoreId(
        userId,
        storeId,
      );

    if (!membership) {
      return null;
    }

    if (membership.activeStatus !== 'active') {
      return null;
    }

    return membership;
  }
}
