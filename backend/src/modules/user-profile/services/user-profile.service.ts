import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/custom-error.js';
import { UserProfileRepository } from '../repositories/user-profile.repository.js';

import type {
  CreateUserProfileDto,
  UpdateUserProfileDto,
  UserProfileResponseDto,
} from '../dtos/user-profile.dto.js';

export class UserProfileService {
  constructor(private readonly userProfileRepository: UserProfileRepository) {}

  public async createUserProfileIfNotExists(
    authUserId: string,
    payload: CreateUserProfileDto,
  ): Promise<UserProfileResponseDto> {
    // check tồn tại
    const existing =
      await this.userProfileRepository.findByAuthUserId(authUserId);

    if (existing) {
      return existing;
    }

    // create mới
    return await this.userProfileRepository.createOne(authUserId, payload);
  }

  public async getUserProfile(
    authUserId: string,
  ): Promise<UserProfileResponseDto> {
    const profile =
      await this.userProfileRepository.findByAuthUserId(authUserId);

    if (!profile) {
      throw new CustomError({
        message: 'Không tìm thấy thông tin người dùng.',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return profile;
  }

  public async updateUserProfile(
    userId: string,
    payload: UpdateUserProfileDto,
  ): Promise<UserProfileResponseDto> {
    const userProfile = await this.userProfileRepository.findById(userId);

    if (!userProfile) {
      throw new CustomError({
        message: 'User profile not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return await this.userProfileRepository.updateOne(userId, payload);
  }
}
