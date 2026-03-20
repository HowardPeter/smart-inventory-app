import { prisma } from '../../../db/prismaClient.js';

import type {
  CreateUserProfileDto,
  UserProfileResponseDto,
} from '../dtos/user-profile.dto.js';

export class UserProfileRepository {
  async findByAuthUserId(
    authUserId: string,
  ): Promise<UserProfileResponseDto | null> {
    return await prisma.userProfile.findUnique({
      where: {
        authUserId,
      },
    });
  }

  async createOne(
    authUserId: string,
    data: CreateUserProfileDto,
  ): Promise<UserProfileResponseDto> {
    return await prisma.userProfile.create({
      data: {
        authUserId,
        email: data.email,
        fullName: data.fullName,
      },
    });
  }
}
