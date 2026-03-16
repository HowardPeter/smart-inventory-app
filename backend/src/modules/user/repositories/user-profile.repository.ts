import { prisma } from '../../../db/prismaClient.js';

import type { UserProfileAuthDTO } from '../dtos/user.dto.js';

export class UserProfileRepository {
  async findByAuthUserId(
    authUserId: string,
  ): Promise<UserProfileAuthDTO | null> {
    return await prisma.userProfile.findUnique({
      where: { authUserId },
      select: {
        userId: true,
        authUserId: true,
        email: true,
        fullName: true,
        activeStatus: true,
      },
    });
  }
}
