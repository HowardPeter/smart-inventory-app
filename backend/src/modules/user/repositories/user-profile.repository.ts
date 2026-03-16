import { prisma } from '../../../db/prismaClient.js';

import type { UserProfileAuthDTO } from '../dtos/user.dto.js';

export class UserProfileRepository {
  async findByAuthUserId(
    authUserId: string,
  ): Promise<UserProfileAuthDTO | null> {
    const userProfile = await prisma.userProfile.findUnique({
      where: { auth_user_id: authUserId },
    });

    if (!userProfile) {
      return null;
    }

    return {
      userId: userProfile.user_id,
      authUserId: userProfile.auth_user_id,
      email: userProfile.email,
      fullName: userProfile.full_name,
      activeStatus: userProfile.active_status,
    };
  }
}
