import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../common/errors/index.js';
import { StoreMemberRepository } from '../store-member/store-member.repository.js';

import type { StoreMemberResponseDto } from '../store-member/store-member.dto.js';

export class StoreMemberService {
  constructor(private readonly storeMemberRepository: StoreMemberRepository) {}

  public async removeUserFromStore(
    targetUserId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto> {
    // 1. Kiểm tra user có đang thuộc store hay không
    const member = await this.storeMemberRepository.findByIds(
      targetUserId,
      storeId,
    );

    if (!member) {
      throw new CustomError({
        message: 'User is not a member of this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // 2. Thực hiện soft delete
    return await this.storeMemberRepository.softDeleteMember(
      targetUserId,
      storeId,
    );
  }
}
