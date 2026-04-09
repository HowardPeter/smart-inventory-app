import type { DbClient } from '../../../common/types/index.js';
import type { StoreRole } from '../../../generated/prisma/client.js';
import type {
  StoreMembershipResponseDto,
  CreateStoreMembershipDto,
} from '../dtos/store-member.dto.js';

export class StoreMemberRepository {
  /* tạo constructor cho các repository có dùng cơ chế $transaction,
  truyền prisma global (prismaClient.ts) lúc bình thường
  và truyền `tx` cho các hàm transaction */
  constructor(private readonly db: DbClient) {}

  async createOne(
    data: CreateStoreMembershipDto,
  ): Promise<StoreMembershipResponseDto> {
    return await this.db.storeMember.create({
      data,
      select: {
        userId: true,
        storeId: true,
        role: true,
        activeStatus: true,
      },
    });
  }

  async findOneByUserIdAndStoreId(
    userId: string,
    storeId: string,
  ): Promise<StoreMembershipResponseDto | null> {
    return await this.db.storeMember.findFirst({
      where: {
        userId,
        storeId,
        activeStatus: 'active',
        store: {
          activeStatus: 'active',
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

  // NOTE: 2 function để disable membership trong store khi store bị xóa
  // async findAllByStoreId(storeId: string): Promise<StoreMembershipList[]> {
  //   return this.db.storeMember.findMany({
  //     where: {
  //       storeId,
  //       activeStatus: 'active',
  //     },
  //     select: {
  //       userId: true,
  //       storeId: true,
  //     },
  //   });
  // }

  // async disableAllStoreMembership(
  //   membershipList: StoreMembershipList[],
  // ): Promise<void> {
  //   await this.db.storeMember.updateMany({
  //     where: {
  //       OR: membershipList.map((membership) => ({
  //         userId: membership.userId,
  //         storeId: membership.storeId,
  //         activeStatus: 'active'
  //       })),
  //     },
  //     data: {
  //       activeStatus: 'inactive',
  //     },
  //   });
  // }

  // Thêm vào class StoreMemberRepository (nếu chưa có)
  async findMembership(userId: string, storeId: string) {
    return await this.db.storeMember.findFirst({
      where: { userId, storeId },
    });
  }

  // Nếu user đã từng tham gia nhưng bị kích (inactive),
  // có thể bạn sẽ cần hàm update để khôi phục
  async reactivateMembership(userId: string, storeId: string, role: StoreRole) {
    return await this.db.storeMember.update({
      where: { userId_storeId: { userId, storeId } },
      data: { activeStatus: 'active', role },
    });
  }
}
