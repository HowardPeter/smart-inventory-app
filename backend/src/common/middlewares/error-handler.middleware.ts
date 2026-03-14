import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../errors/index.js';
import { sendResponse } from '../utils/index.js';
import { logger } from '../utils/logger.util.js';

import type { Request, Response, NextFunction } from 'express';

export const errorHandler = (
  err: unknown,
  req: Request,
  res: Response,
  _next: NextFunction,
) => {
  logger.error(
    {
      err,
      path: req.originalUrl,
      method: req.method,
    },
    'Request failed',
  );

  if (err instanceof CustomError) {
    return sendResponse.error(res, err.status, err.message);
  }

  if (err instanceof Error) {
    return sendResponse.error(
      res,
      StatusCodes.INTERNAL_SERVER_ERROR,
      err.message,
    );
  }

  return sendResponse.error(
    res,
    StatusCodes.INTERNAL_SERVER_ERROR,
    'Internal Server Error',
  );
};
