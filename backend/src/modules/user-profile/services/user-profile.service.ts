import { UserProfileRepository } from '../repositories/user-profile.repository.js';

import type {
  CreateUserProfileDto,
  UserProfileResponseDto,
} from '../dtos/user-profile.dto.js';

export class UserProfileService {
  constructor(
    private readonly userProfileRepository: UserProfileRepository,
  ) {}

  public async createUserProfileIfNotExists(
    authUserId: string,
    payload: CreateUserProfileDto,
  ): Promise<UserProfileResponseDto> {
    // 🔥 check tồn tại
    const existing =
      await this.userProfileRepository.findByAuthUserId(authUserId);

    if (existing) {
      return existing;
    }

    // 🔥 create mới
    return await this.userProfileRepository.createOne(
      authUserId,
      payload,
    );
  }
}
