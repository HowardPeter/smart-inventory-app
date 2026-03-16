import { registerUser } from '../auth/services/auth.service.js';

import type { Request, Response } from 'express';

export const registerController = async (req: Request, res: Response) => {
  try {
    const user = await registerUser(req.body);

    return res.status(201).json({
      message: 'Register success',
      data: user,
    });
  } catch (error: any) {
    return res.status(400).json({
      message: error.message,
    });
  }
};
