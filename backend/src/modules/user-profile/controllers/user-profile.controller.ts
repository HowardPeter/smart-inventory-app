import { StatusCodes } from 'http-status-codes';

import { requireReqUser, sendResponse } from '../../../common/utils/index.js';
import { UserProfileService } from '../services/user-profile.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  CreateUserProfileDto,
  UserProfileResponseDto,
} from '../dtos/user-profile.dto.js';
import type { Request, Response } from 'express';

export class UserProfileController {
  constructor(private readonly userProfileService: UserProfileService) {}

  createMyProfile = async (
    req: Request,
    res: Response<ApiResponse<UserProfileResponseDto>>,
  ): Promise<void> => {
    const user = requireReqUser(req);

    const payload = req.body as CreateUserProfileDto;

    const profile = await this.userProfileService.createUserProfileIfNotExists(
      user.authUserId!,
      {
        email: user.email ?? '',
        fullName: payload.fullName ?? '',
      },
    );

    sendResponse.success(res, profile, {
      status: StatusCodes.CREATED,
    });
  };
}
