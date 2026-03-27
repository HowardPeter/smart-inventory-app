// src/modules/notification/controllers/notification.controller.ts
import { StatusCodes } from 'http-status-codes';

import { requireReqUser, sendResponse } from '../../../common/utils/index.js';
import { NotificationService } from '../services/notification.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  RegisterTokenDto,
  RemoveTokenDto,
  FcmTokenResponseDto,
} from '../dto/notification.dto.js';
import type { Request, Response } from 'express';

export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  registerToken = async (
    req: Request,
    res: Response<ApiResponse<FcmTokenResponseDto>>,
  ): Promise<void> => {
    const user = requireReqUser(req);
    const payload = req.body as RegisterTokenDto;

    const registeredToken = await this.notificationService.registerToken(
      user.userId,
      payload,
    );

    sendResponse.success(res, registeredToken, { status: StatusCodes.OK });
  };

  removeToken = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    // Không bắt buộc phải login khi remove token
    // (đề phòng token bị treo khi phiên đã hết hạn)
    // Nếu route của bạn bắt buộc authenticate

    // thì có thể dùng requireReqUser ở đây.
    const payload = req.body as RemoveTokenDto;

    await this.notificationService.removeToken(payload);

    sendResponse.success(res, null, { status: StatusCodes.OK });
  };

  // Hàm test notification
  // Thêm hàm này vào NotificationController
  testSend = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const user = requireReqUser(req);
    const { title, body, dataPayload } = req.body;

    // Đã xóa chữ 'ToUser'
    await this.notificationService.sendNotification(
      user.userId,
      title,
      body,
      dataPayload,
    );

    sendResponse.success(res, null, { status: StatusCodes.OK });
  };
}
