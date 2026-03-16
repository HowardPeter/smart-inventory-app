import { UserProfileService } from './services/user-profile.service.js';

import type { UserProfileAuthDTO } from './dtos/user.dto.js';

/* Lớp Facade trung gian để các module khác có thể gọi đến
mà không cần quan tâm đến chi tiết của service */
export class UserFacade {
  constructor(private readonly userProfileService: UserProfileService) {}

  async getActiveUserByAuthUserId(
    authUserId: string,
  ): Promise<UserProfileAuthDTO | null> {
    return this.userProfileService.getActiveUserByAuthUserId(authUserId);
  }
}
