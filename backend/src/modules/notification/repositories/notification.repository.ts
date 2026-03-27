// src/modules/notification/repositories/notification.repository.ts
import { prisma } from '../../../db/prismaClient.js';

import type { FcmTokenResponseDto } from '../dto/notification.dto.js';

export class NotificationRepository {
  async upsertToken(
    userId: string,
    token: string,
  ): Promise<FcmTokenResponseDto> {
    return await prisma.fcmToken.upsert({
      where: { token },
      update: { userId },
      create: { token, userId },
      select: {
        tokenId: true,
        token: true,
        userId: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async deleteTokensByValue(token: string): Promise<void> {
    await prisma.fcmToken.deleteMany({
      where: { token },
    });
  }

  async findTokensByUserId(userId: string): Promise<FcmTokenResponseDto[]> {
    return await prisma.fcmToken.findMany({
      where: { userId },
      select: {
        tokenId: true,
        token: true,
        userId: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }
}
