import { StatusCodes } from 'http-status-codes';

import { requireReqUser, sendResponse } from '../../../common/utils/index.js';
import { NotificationService } from '../services/notification.service.js';

import type { Request, Response } from 'express';

export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  // Quản lý Token
  registerToken = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    const { token } = req.body;
    const data = await this.notificationService.registerToken(
      user.userId,
      token,
    );

    sendResponse.success(res, data, { status: StatusCodes.OK });
  };

  removeToken = async (req: Request, res: Response): Promise<void> => {
    const { token } = req.body;

    await this.notificationService.removeToken(token);
    sendResponse.success(res, null, { status: StatusCodes.OK });
  };

  // API Lấy danh sách thông báo

  getNotifications = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    const notifications = await this.notificationService.getUserNotifications(
      user.userId,
    );

    sendResponse.success(res, notifications, { status: StatusCodes.OK });
  };

  // API Đánh dấu đã đọc
  markAsRead = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    // Thay đổi cách lấy params và ép kiểu thành string
    const notificationId = req.params.notificationId as string;

    await this.notificationService.markAsRead(user.userId, notificationId);
    sendResponse.success(res, null, {
      status: StatusCodes.OK,
      message: 'Đã đánh dấu đọc',
    });
  };

  // API Xóa mềm
  deleteNotification = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    // Thay đổi cách lấy params và ép kiểu thành string
    const notificationId = req.params.notificationId as string;

    await this.notificationService.softDeleteNotification(
      user.userId,
      notificationId,
    );
    sendResponse.success(res, null, {
      status: StatusCodes.OK,
      message: 'Đã xóa thông báo',
    });
  };

  // API Test gửi thông báo từ Postman
  testSend = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    const { title, body, type, referenceId } = req.body;

    await this.notificationService.createAndSendNotification(
      user.userId,
      title,
      body,
      type,
      referenceId,
    );
    sendResponse.success(res, null, { status: StatusCodes.OK });
  };
}
