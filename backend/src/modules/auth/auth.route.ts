import { Router } from 'express';

import {
  registerController,
  verifyEmailController,
} from '../auth/auth.controller.js';

const router = Router();

router.post('/register', registerController);

router.get('/callback', verifyEmailController);

export default router;
