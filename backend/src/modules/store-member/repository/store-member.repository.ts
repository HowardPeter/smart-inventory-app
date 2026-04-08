import { prisma } from '../../../db/prismaClient.js';

import type { StoreRole } from '../../../generated/prisma/enums.js';
import type {
  RawStoreMemberDto,
  StoreMemberResponseDto,
} from '../dto/store-member.dto.js';

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

  async updateRole(
    userId: string,
    storeId: string,
    newRole: StoreRole,
  ): Promise<StoreMemberResponseDto> {
    return await prisma.storeMember.update({
      where: {
        userId_storeId: {
          userId,
          storeId,
        },
      },
      data: {
        role: newRole,
      },
    });
  }

  async findManyByStoreId(storeId: string): Promise<RawStoreMemberDto[]> {
    return (await prisma.storeMember.findMany({
      where: {
        storeId,
        activeStatus: 'active',
        user: {
          activeStatus: 'active',
        },
      },
      select: {
        role: true,
        joinedAt: true,
        user: {
          select: {
            userId: true,
            email: true,
            fullName: true,
            phone: true,
            address: true,
            activeStatus: true,
            createdAt: true,
            updatedAt: true,
            authUserId: true,
          },
        },
      },
    })) as unknown as RawStoreMemberDto[];
  }
}
