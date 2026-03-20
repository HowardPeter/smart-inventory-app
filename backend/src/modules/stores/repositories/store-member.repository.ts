import type { DbClient } from '../../../common/types/index.js';
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
      },
      select: {
        userId: true,
        storeId: true,
        role: true,
      },
    });
  }
}
