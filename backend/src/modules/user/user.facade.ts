import { UserProfileService } from './services/user-profile.service.js';

import type { UserProfileAuthDTO } from './dtos/user.dto.js';

export class UserFacade {
  constructor(private readonly userProfileService: UserProfileService) {}

  async getActiveUserByAuthUserId(
    authUserId: string,
  ): Promise<UserProfileAuthDTO | null> {
    return this.userProfileService.getActiveUserByAuthUserId(authUserId);
  }
}
