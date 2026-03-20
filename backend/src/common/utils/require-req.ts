import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../errors/custom-error.js';

import type { CurrentUser, StoreContext } from '../types/index.js';
import type { Request } from 'express';

/* util để fix lỗi req.user undefined,
cần check req.user tồn tại trước khi gọi req.user
vì req.user không phải là trường mặc định trong Request */
export const requireReqUser = (req: Request): CurrentUser => {
  if (!req.user) {
    throw new CustomError({
      message: 'User is not authenticated',
      status: StatusCodes.UNAUTHORIZED,
    });
  }

  return req.user;
};

export const requireReqStoreContext = (req: Request): StoreContext => {
  if (!req.storeContext) {
    throw new CustomError({
      message: 'Cannot get store ID',
      status: StatusCodes.BAD_REQUEST,
    });
  }

  return req.storeContext;
};
