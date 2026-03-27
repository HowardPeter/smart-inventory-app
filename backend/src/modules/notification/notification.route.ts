// src/modules/notification/routes/notification.route.ts
import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
//import { validate } from '../../common/validators/index.js';
import { authenticate } from '../auth/index.js';
import { notificationController } from '../notification/notification.module.js';
import { validate } from './validators/validate.middleware.js';
import {
  registerTokenSchema,
  removeTokenSchema,
} from '../notification/validators/notification.validator.js';

const notificationRouter = Router();

// Endpoint đăng ký token yêu cầu user phải đăng nhập
notificationRouter.post(
  '/register-token',
  authenticate,
  validate(registerTokenSchema),
  asyncWrapper(notificationController.registerToken),
);

// Endpoint xóa token (khi logout)
notificationRouter.post(
  '/remove-token',
  validate(removeTokenSchema),
  asyncWrapper(notificationController.removeToken),
);

notificationRouter.post(
  '/test-send',
  authenticate, // Lấy userId từ token
  asyncWrapper(notificationController.testSend),
);

export { notificationRouter };
