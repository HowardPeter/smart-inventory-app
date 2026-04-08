import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { requireReqUser, sendResponse } from '../../../common/utils/index.js';
import { UserProfileService } from '../services/user-profile.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  CreateUserProfileDto,
  UpdateUserProfileDto,
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

  getMyProfile = async (
    req: Request,
    res: Response<ApiResponse<UserProfileResponseDto>>,
  ): Promise<void> => {
    const user = requireReqUser(req);

    const profile = await this.userProfileService.getUserProfile(
      user.authUserId!,
    );

    sendResponse.success(res, profile, {
      status: StatusCodes.OK,
    });
  };

  updateUserProfile = async (
    req: Request,
    res: Response<ApiResponse<UserProfileResponseDto>>,
  ): Promise<void> => {
    requireReqUser(req);

    const { userId } = req.params;
    const payload = req.body as UpdateUserProfileDto;

    if (!userId || typeof userId !== 'string') {
      throw new CustomError({
        message: 'User ID is required and must be a valid string',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const updatedProfile = await this.userProfileService.updateUserProfile(
      userId,
      payload,
    );

    sendResponse.success(res, updatedProfile, { status: StatusCodes.OK });
  };
}
