import { prisma } from '../../../db/prismaClient.js';

export class NotificationRepository {
  // --- XỬ LÝ FCM TOKEN ---
  async upsertToken(userId: string, token: string) {
    return await prisma.fcmToken.upsert({
      where: { token },
      update: { userId },
      create: { token, userId },
    });
  }

  async deleteTokensByValue(token: string) {
    await prisma.fcmToken.deleteMany({ where: { token } });
  }

  async findTokensByUserId(userId: string) {
    return await prisma.fcmToken.findMany({ where: { userId } });
  }

  // --- XỬ LÝ IN-APP NOTIFICATION ---
  async createNotification(
    userId: string,
    title: string,
    body: string,
    type: string,
    referenceId?: string,
  ) {
    return await prisma.notification.create({
      data: { userId, title, body, type, referenceId: referenceId ?? null },
    });
  }

  async getUserNotifications(userId: string) {
    return await prisma.notification.findMany({
      where: { userId, activeStatus: 'active' }, // Lấy danh sách chưa bị xóa mềm
      orderBy: { createdAt: 'desc' },
    });
  }

  async markAsRead(userId: string, notificationId: string) {
    return await prisma.notification.updateMany({
      where: { notificationId, userId, activeStatus: 'active' },
      data: { isRead: true },
    });
  }

  async softDelete(userId: string, notificationId: string) {
    return await prisma.notification.updateMany({
      where: { notificationId, userId },
      data: { activeStatus: 'inactive' }, // Xóa mềm
    });
  }
}
