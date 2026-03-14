import type { ApiErrorResponse, ApiSuccessResponse } from '../types/index.js';
import type { Response } from 'express';

export const sendResponse = {
  success: <T>(
    res: Response,
    data: T,
    options?: {
      status?: number;
      message?: string;
      meta?: Record<string, unknown>;
    },
  ) => {
    const response: ApiSuccessResponse<T> = {
      success: true,
      data,
    };

    if (options?.message !== undefined) {
      response.message = options.message;
    }

    if (options?.meta !== undefined) {
      response.meta = options.meta;
    }

    return res.status(options?.status ?? 200).json(response);
  },

  error: (
    res: Response,
    status: number,
    message: string,
  ) => {
    const response: ApiErrorResponse = {
      success: false,
      status,
      message,
    };

    return res.status(status).json(response);
  },
};
