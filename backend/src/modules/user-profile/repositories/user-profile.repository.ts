import { prisma } from '../../../db/prismaClient.js';

import type {
  CreateUserProfileDto,
  UpdateUserProfileDto,
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

  async findById(userId: string): Promise<UserProfileResponseDto | null> {
    return await prisma.userProfile.findUnique({
      where: { userId },
    });
  }

  async updateOne(
    userId: string,
    data: UpdateUserProfileDto,
  ): Promise<UserProfileResponseDto> {
    return await prisma.userProfile.update({
      where: { userId },
      data,
    });
  }
}
