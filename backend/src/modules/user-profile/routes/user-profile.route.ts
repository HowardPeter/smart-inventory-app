import { Router } from 'express';

import { asyncWrapper } from '../../../common/middlewares/index.js';
import { authenticate } from '../../auth/index.js';
// Import middleware mới vừa tách
import { verifyAuthOnly } from '../../user-profile/middleware/optional-profile.middleware.js';
import { userProfileController } from '../user-profile.module.js';

const router = Router();

router.post(
  '/me/profile',
  verifyAuthOnly,
  asyncWrapper(userProfileController.createMyProfile),
);

router.get(
  '/me',
  authenticate,
  asyncWrapper(userProfileController.getMyProfile),
);

export { router as userProfileRouter };
