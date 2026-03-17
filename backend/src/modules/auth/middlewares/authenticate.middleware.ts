import { authSessionService } from '../services/auth-session.service.js';

import type { AuthenticatedRequest } from '../../../common/types/index.js';
import type { NextFunction, Response } from 'express';

export const authenticate = async (
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const currentUser = await authSessionService.authenticateRequest(req);

    req.user = currentUser;

    next();
  } catch (error) {
    next(error);
  }
};
