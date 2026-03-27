import { getMessaging, type MulticastMessage } from 'firebase-admin/messaging';

import { NotificationRepository } from '../repositories/notification.repository.js';

export class NotificationService {
  constructor(
    private readonly notificationRepository: NotificationRepository,
  ) {}

  // Quản lý Token
  public async registerToken(userId: string, token: string) {
    return await this.notificationRepository.upsertToken(userId, token);
  }

  public async removeToken(token: string) {
    await this.notificationRepository.deleteTokensByValue(token);
  }

  // --- LUỒNG CHÍNH: LƯU DB VÀ BẮN PUSH ---
  public async createAndSendNotification(
    userId: string,
    storeId: string, // 👉 Bổ sung tham số storeId
    title: string,
    body: string,
    type: string,
    referenceId?: string,
  ): Promise<void> {
    // 1. Lưu vào Database
    const newNoti = await this.notificationRepository.createNotification(
      userId,
      storeId, // 👉 Truyền storeId xuống Repo
      title,
      body,
      type,
      referenceId,
    );

    // 2. Lấy Token để bắn Push
    const tokens = await this.notificationRepository.findTokensByUserId(userId);

    console.info(`[FCM] Tìm thấy ${tokens.length} tokens cho user ${userId}`);
    if (tokens.length === 0) {
      return;
    }

    // 3. Đóng gói Payload chuẩn
    const message: MulticastMessage = {
      notification: { title, body },
      data: {
        notificationId: newNoti.notificationId,
        type: newNoti.type,
        referenceId: newNoti.referenceId ?? '',
      },
      tokens: tokens.map((t) => t.token),
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'high_importance_channel',
        },
      },
      apns: { payload: { aps: { sound: 'default' } } },
    };

    // 4. Bắn qua Firebase
    try {
      const response = await getMessaging().sendEachForMulticast(message);

      console.info(
        `[FCM] Gửi thành công: ${response.successCount}, Lỗi: ${response.failureCount}`,
      );
    } catch (error) {
      console.error('Lỗi gửi push notification:', error);
    }
  }

  // Cung cấp dữ liệu cho API Frontend
  public async getUserNotifications(userId: string, storeId: string) {
    // 👉 Thêm tham số storeId
    return await this.notificationRepository.getUserNotifications(
      userId,
      storeId,
    ); // 👉 Đồng bộ với Repo
  }

  public async markAsRead(userId: string, notificationId: string) {
    await this.notificationRepository.markAsRead(userId, notificationId);
  }

  public async softDeleteNotification(userId: string, notificationId: string) {
    await this.notificationRepository.softDelete(userId, notificationId);
  }
}
