import { prisma } from '../../../db/prismaClient.js';

import type { StoreMembershipResponseDto } from '../dtos/store-member.dto.js';

export class StoreMemberRepository {
  async findMembershipByUserIdAndStoreId(
    userId: string,
    storeId: string,
  ): Promise<StoreMembershipResponseDto | null> {
    return prisma.storeMember.findUnique({
      where: {
        userId_storeId: {
          userId,
          storeId,
        },
      },
      select: {
        userId: true,
        storeId: true,
        role: true,
        activeStatus: true,
      },
    });
  }
}
