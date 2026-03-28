import type { FcmToken } from '../notification.type.js';

export type FcmTokenResponseDto = FcmToken;

// userId sẽ được lấy từ token (req.user), client chỉ cần gửi fcm token
export type RegisterTokenDto = Pick<FcmToken, 'token'>;

export type RemoveTokenDto = Pick<FcmToken, 'token'>;
