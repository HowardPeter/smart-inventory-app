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
    const storeId = req.headers['x-store-id'] as string;

    const page = parseInt(req.query.page as string) || 1;
    const size = parseInt(req.query.size as string) || 15;

    if (!storeId) {
      res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        message: 'Thiếu x-store-id trong Header',
      });

      return;
    }

    const notifications = await this.notificationService.getUserNotifications(
      user.userId,
      storeId,
      page,
      size,
    );

    sendResponse.success(res, notifications, { status: StatusCodes.OK });
  };

  // API Đánh dấu đã đọc
  markAsRead = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
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

  // Thêm API này
  markAllAsRead = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    const storeId = req.headers['x-store-id'] as string;

    if (!storeId) {
      res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        message: 'Thiếu x-store-id trong Header',
      });

      return;
    }

    await this.notificationService.markAllAsRead(user.userId, storeId);
    sendResponse.success(res, null, {
      status: StatusCodes.OK,
      message: 'Đã đánh dấu đọc tất cả',
    });
  };

  // API Test gửi thông báo từ Postman
  testSend = async (req: Request, res: Response): Promise<void> => {
    const user = requireReqUser(req);
    const storeId = req.headers['x-store-id'] as string; // 👉 Bắt storeId từ Header

    if (!storeId) {
      res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        message: 'Thiếu x-store-id trong Header',
      });

      return;
    }

    const { title, body, type, referenceId } = req.body;

    await this.notificationService.createAndSendNotification(
      user.userId,
      storeId, // 👉 Truyền storeId xuống Service
      title,
      body,
      type,
      referenceId,
    );
    sendResponse.success(res, null, { status: StatusCodes.OK });
  };
}
