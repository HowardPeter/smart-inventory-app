import { prisma } from '../../../db/prismaClient.js';

import type { StoreMembershipResponseDto } from '../dtos/store-member.dto.js';

export class StoreMemberRepository {
  async findMembershipByUserIdAndStoreId(
    userId: string,
    storeId: string,
  ): Promise<StoreMembershipResponseDto | null> {
    return prisma.storeMember.findFirst({
      where: {
        userId,
        storeId,
        activeStatus: 'active',
      },
      select: {
        userId: true,
        storeId: true,
        role: true,
      },
    });
  }
}
