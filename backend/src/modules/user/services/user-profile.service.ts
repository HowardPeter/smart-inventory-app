import { UserProfileRepository } from '../repositories/user-profile.repository.js';

import type { UserProfileAuthDTO } from '../dtos/user.dto.js';

export class UserProfileService {
  constructor(private readonly userProfileRepository: UserProfileRepository) {}

  async getActiveUserByAuthUserId(
    authUserId: string,
  ): Promise<UserProfileAuthDTO | null> {
    const userProfile =
      await this.userProfileRepository.findByAuthUserId(authUserId);

    if (!userProfile) {
      return null;
    }

    if (userProfile.activeStatus !== 'active') {
      return null;
    }

    return userProfile;
  }
}
