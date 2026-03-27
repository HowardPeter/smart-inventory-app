// src/modules/notification/index.ts
export { notificationRouter } from '../notification/notification.route.js';
export { notificationService } from './notification.module.js';
export type {
  RegisterTokenDto,
  RemoveTokenDto,
  FcmTokenResponseDto,
} from '../notification/dto/notification.dto.js';
