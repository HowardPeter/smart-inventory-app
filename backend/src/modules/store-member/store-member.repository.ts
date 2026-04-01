import { prisma } from '../../db/prismaClient.js';

import type { StoreMemberResponseDto } from './store-member.dto.js';

export class StoreMemberRepository {
  async findByIdsWithStore(
    userId: string,
    storeId: string,
  ): Promise<(StoreMemberResponseDto & { store: { userId: string } }) | null> {
    return await prisma.storeMember.findUnique({
      where: {
        userId_storeId: { userId, storeId },
      },
      include: {
        store: {
          select: { userId: true }, // Lấy ID của chủ cửa hàng (Owner)
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
