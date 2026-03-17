import { registerUserService } from '../auth/services/auth.service.js';
import { registerSchema } from '../auth/validators/register-email-pw.validator.js';

import type { Request, Response } from 'express';

export const registerController = async (req: Request, res: Response) => {
  try {
    const parsed = registerSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json({
        success: false,
        message: 'Invalid input',
        errors: parsed.error.flatten(),
      });
    }

    await registerUserService(parsed.data);

    return res.status(201).json({
      success: true,
      message:
        'Registration successful. Please check your email to verify your account.',
    });
  } catch (error: unknown) {
    console.error('REGISTER ERROR:', {
      body: req.body,
      error,
    });

    if (error instanceof Error) {
      if (error.message.includes('already')) {
        return res.status(409).json({
          success: false,
          message: error.message,
        });
      }

      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

export const verifyEmailController = (req: Request, res: Response) => {
  try {
    return res.status(200).send(`
      <h2>Email verified successfully ✅</h2>
      <p>You can now login to the application.</p>
    `);
  } catch (error) {
    console.error('Verify email error:', error);

    return res.status(500).send(`
      <h2>Email verification failed ❌</h2>
      <p>Please try again or request a new verification email.</p>
    `);
  }
};
