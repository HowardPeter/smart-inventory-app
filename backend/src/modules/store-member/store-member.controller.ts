import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../common/errors/custom-error.js';
import { sendResponse } from '../../common/utils/api-response.util.js';
import { requireReqStoreContext } from '../../common/utils/require-req.js';

import type { StoreMemberResponseDto } from './store-member.dto.js';
import type { StoreMemberService } from './store-member.service.js';
import type { ApiResponse } from '../../common/types/api-response.type.js';
import type { Request, Response } from 'express';

export class StoreMemberController {
  constructor(private readonly storeMemberService: StoreMemberService) {}

  removeUser = async (
    req: Request,
    res: Response<ApiResponse<StoreMemberResponseDto>>,
  ): Promise<void> => {
    // Lấy context store hiện tại của requester (Manager/Owner đang thao tác)
    const storeContext = requireReqStoreContext(req);
    const userId = req.params.userId as string;

    if (!userId) {
      throw new CustomError({
        message: 'Target User ID is required',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const removedMember = await this.storeMemberService.removeUserFromStore(
      userId,
      storeContext.storeId,
    );

    // Trả kết quả chuẩn của dự án SIS
    sendResponse.success(res, removedMember, { status: StatusCodes.OK });
  };
}
