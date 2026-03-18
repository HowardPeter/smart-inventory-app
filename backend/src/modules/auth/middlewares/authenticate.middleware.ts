import { authSessionService } from '../services/auth-session.service.js';

import type { Request, NextFunction, Response } from 'express';

export const authenticate = async (
  req: Request,
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
