import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/custom-error.js';
import { sendResponse } from '../../../common/utils/api-response.util.js';
import {
  requireReqStoreContext,
  requireReqUser,
} from '../../../common/utils/require-req.js';

import type { ApiResponse } from '../../../common/types/api-response.type.js';
import type { StoreMemberResponseDto } from '../dto/store-member.dto.js';
import type { StoreMemberService } from '../service/store-member.service.js';
import type { Request, Response } from 'express';

export class StoreMemberController {
  constructor(private readonly storeMemberService: StoreMemberService) {}

  removeUser = async (
    req: Request,
    res: Response<ApiResponse<StoreMemberResponseDto>>,
  ): Promise<void> => {
    const user = requireReqUser(req);
    // Lấy ID của người đang thao tác [cite: 338, 355]
    const storeContext = requireReqStoreContext(req);
    // Có chứa storeId và role ('owner', 'manager', 'staff') [cite: 412-417]
    const targetUserId = req.params.userId as string; // Target User ID muốn xóa

    if (!targetUserId) {
      throw new CustomError({
        message: 'Target User ID is required',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const removedMember = await this.storeMemberService.removeUserFromStore(
      user.userId, // Ai đang xoá?
      storeContext.role, // Role của người xoá là gì?
      targetUserId, // Xoá ai?
      storeContext.storeId, // Ở store nào?
    );

    sendResponse.success(res, removedMember, { status: StatusCodes.OK });
    // [cite: 430]
  };
}
