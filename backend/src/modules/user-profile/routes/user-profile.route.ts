import { Router } from 'express';

import { asyncWrapper } from '../../../common/middlewares/index.js';
//import { authenticate } from '../../auth/index.js';
import { authenticate } from '../../auth/index.js';
import { supabaseAuthProvider } from '../../auth/providers/supabase-auth.provider.js';
import { authSessionService } from '../../auth/services/auth-session.service.js';
import { userProfileController } from '../user-profile.module.js';

const router = Router();

//router.use(authenticate);

// Tạo một middleware tạm thời hoặc sửa lại authenticate để linh hoạt hơn
router.post(
  '/me/profile',
  async (req, res, next) => {
    try {
      // Chỉ xác thực token, không bắt buộc có profile trong DB
      const accessToken = authSessionService.extractAccessToken(req);
      const { user } =
        await supabaseAuthProvider.verifyAccessToken(accessToken);

      // Gán thông tin tối thiểu vào req.user để Controller sử dụng
      req.user = {
        userId: '',
        authUserId: user.id!,
        email: user.email!,
      };
      next();
    } catch (error) {
      next(error);
    }
  },
  asyncWrapper(userProfileController.createMyProfile),
);

router.get(
  '/me',
  authenticate,
  asyncWrapper(userProfileController.getMyProfile),
);

export { router as userProfileRouter };
