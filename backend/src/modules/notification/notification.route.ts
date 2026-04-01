import { Router } from 'express';

import { NotificationController } from './controllers/notification.controller.js';
import { NotificationRepository } from './repositories/notification.repository.js';
import { NotificationService } from './services/notification.service.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../auth/index.js';
import {
  registerTokenSchema,
  removeTokenSchema,
} from './validators/notification.validator.js';
import { validate } from '../notification/validators/validate.middleware.js';


const notificationRouter = Router();
const repository = new NotificationRepository();

const service = new NotificationService(repository);
const controller = new NotificationController(service);

notificationRouter.post(
  '/register-token',
  authenticate,
  validate(registerTokenSchema),
  asyncWrapper(controller.registerToken),
);

notificationRouter.post(
  '/remove-token',
  authenticate,
  validate(removeTokenSchema),
  asyncWrapper(controller.removeToken),
);

notificationRouter.post(
  '/test-send',
  authenticate,
  asyncWrapper(controller.testSend),
);

// Các route cho App
notificationRouter.get(
  '/',
  authenticate,
  asyncWrapper(controller.getNotifications),
);

notificationRouter.patch(
  '/:notificationId/read',
  authenticate,
  asyncWrapper(controller.markAsRead),
);

notificationRouter.delete(
  '/:notificationId',
  authenticate,
  asyncWrapper(controller.deleteNotification),
);

notificationRouter.patch(
  '/read-all',
  authenticate,
  asyncWrapper(controller.markAllAsRead),
);

export default notificationRouter;
