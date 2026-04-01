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
    // 1. Lấy thông tin member kèm theo thông tin chủ cửa hàng
    const member = await this.storeMemberRepository.findByIdsWithStore(
      targetUserId,
      storeId,
    );

    // Lỗi 404: User không tồn tại trong danh sách thành viên của Store
    if (!member) {
      throw new CustomError({
        message: 'User is not a member of this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // Lỗi logic 1: User này vốn đã bị xoá (inactive) từ trước rồi
    if (member.activeStatus === 'inactive') {
      throw new CustomError({
        message: 'This user has already been removed from the store',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    // Lỗi bảo mật 2: Không được phép xoá Owner
    // (Chủ cửa hàng) ra khỏi Store của chính họ
    if (member.store.userId === targetUserId) {
      throw new CustomError({
        message: 'Cannot remove the store owner',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // 2. Nếu mọi thứ hợp lệ, thực hiện Soft Delete [cite: 662, 727]
    return await this.storeMemberRepository.softDeleteMember(
      targetUserId,
      storeId,
    );
  }
}
