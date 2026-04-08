import { Router } from 'express';

import { asyncWrapper, validator } from '../../../common/middlewares/index.js';
import { authenticate } from '../../auth/index.js';
// Import middleware mới vừa tách
import { verifyAuthOnly } from '../../user-profile/middleware/optional-profile.middleware.js';
import { userProfileRouter } from '../index.js';
import { userProfileController } from '../user-profile.module.js';
import { updateUserProfileSchema } from '../validator/user-profile.validator.js';

const router = Router();

userProfileRouter.use(authenticate);

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

userProfileRouter.patch(
  '/:userId',
  validator(updateUserProfileSchema),
  asyncWrapper(userProfileController.updateUserProfile),
);

export { router as userProfileRouter };
