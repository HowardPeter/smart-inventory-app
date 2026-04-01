import { prisma } from '../../db/prismaClient.js';

import type { StoreMemberResponseDto } from './store-member.dto.js';

export class StoreMemberRepository {
  async findByIds(
    userId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto | null> {
    return await prisma.storeMember.findUnique({
      where: {
        userId_storeId: {
          userId,
          storeId,
        },
      },
    });
  }

  async softDeleteMember(
    userId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto> {
    return await prisma.storeMember.update({
      where: {
        userId_storeId: {
          userId,
          storeId,
        },
      },
      data: {
        activeStatus: 'inactive', // Soft delete theo business rule của SIS
      },
    });
  }
}
