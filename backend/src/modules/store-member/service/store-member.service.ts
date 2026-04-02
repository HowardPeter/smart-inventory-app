import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { StoreMemberRepository } from '../repository/store-member.repository.js';

import type { StoreMemberResponseDto } from '../dto/store-member.dto.js';

export class StoreMemberService {
  constructor(private readonly storeMemberRepository: StoreMemberRepository) {}

  public async removeUserFromStore(
    requesterUserId: string,
    requesterRole: string,
    targetUserId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto> {
    // 1. Lấy thông tin member bị xoá
    const targetMember = await this.storeMemberRepository.findByIdsWithStore(
      targetUserId,
      storeId,
    );

    if (!targetMember) {
      throw new CustomError({
        message: 'User is not a member of this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (targetMember.activeStatus === 'inactive') {
      throw new CustomError({
        message: 'This user has already been removed from the store',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    // 2. Chặn tự xóa chính mình
    // (nếu muốn tự out thì nên làm 1 API /leave riêng)
    if (requesterUserId === targetUserId) {
      throw new CustomError({
        message: 'You cannot remove yourself using this feature',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    // 3. Chặn tuyệt đối việc xoá Owner của Store
    if (targetMember.store.userId === targetUserId) {
      throw new CustomError({
        message: 'Cannot remove the store owner',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // 4. ÁP DỤNG LUẬT PHÂN CẤP (HIERARCHY RULES)
    // Nếu requester là 'manager', họ không được phép xoá một 'manager' khác
    if (requesterRole === 'manager' && targetMember.role === 'manager') {
      throw new CustomError({
        message: 'Managers can only remove staff members, not other managers',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // Ghi chú: Nếu requesterRole là 'owner',
    // code sẽ lướt qua if trên và đi tiếp xuống dưới.
    // Nếu targetMember.role là 'staff', code cũng đi tiếp bình thường.

    // 5. Hợp lệ tất cả -> Xoá mềm
    return await this.storeMemberRepository.softDeleteMember(
      targetUserId,
      storeId,
    );
  }
}
