import { getMessaging, type MulticastMessage } from 'firebase-admin/messaging';

import { NotificationRepository } from '../repositories/notification.repository.js';

import type {
  FcmTokenResponseDto,
  RegisterTokenDto,
  RemoveTokenDto,
} from '../dto/notification.dto.js';

export class NotificationService {
  constructor(
    private readonly notificationRepository: NotificationRepository,
  ) {}

  public async registerToken(
    userId: string,
    payload: RegisterTokenDto,
  ): Promise<FcmTokenResponseDto> {
    return await this.notificationRepository.upsertToken(userId, payload.token);
  }

  public async removeToken(payload: RemoveTokenDto): Promise<void> {
    await this.notificationRepository.deleteTokensByValue(payload.token);
  }

  // Hàm này có thể được gọi bởi các Service khác
  // (VD: OrderService) khi cần gửi thông báo
  public async sendNotification(
    userId: string,
    title: string,
    body: string,
    dataPayload?: Record<string, string>,
  ): Promise<void> {


    const tokens = await this.notificationRepository.findTokensByUserId(userId);

    // Đổi console.log thành console.info để chiều lòng ESLint
    console.info(`[FCM] Tìm thấy ${tokens.length} tokens cho user ${userId}`);
    if (tokens.length === 0) {
      return;
    }

    // Ép kiểu rõ ràng là MulticastMessage và chưa đưa dataPayload vào vội
    const message: MulticastMessage = {
      notification: { title, body },
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

    if (dataPayload) {
      message.data = dataPayload;
    }

    try {
      const response = await getMessaging().sendEachForMulticast(message);

      // Đổi console.log thành console.info
      console.info(
        `[FCM] Gửi thành công: ${response.successCount}, Lỗi: ${response.failureCount}`,
      );
    } catch (error) {
      console.error('Lỗi gửi push notification:', error);
    }
  }
}
