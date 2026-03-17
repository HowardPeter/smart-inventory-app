import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import { storeMemberService } from '../store.module.js';

import type { AuthorizedRequest } from '../../../common/types/index.js';
import type { Response, NextFunction } from 'express';

export const requireStoreContext = async (
  req: AuthorizedRequest,
  _res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const storeId = req.header('x-store-id');

    if (!storeId) {
      throw new CustomError({
        message: 'Store ID is required in the x-store-id header',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const membership = await storeMemberService.getMembershipByUserIdAndStoreId(
      req.user.userId,
      storeId,
    );

    if (!membership) {
      throw new CustomError({
        message: 'User does not have access to the specified store',
        status: StatusCodes.FORBIDDEN,
      });
    }

    req.storeContext = {
      storeId,
      role: membership.role,
    };
  } catch (error) {
    next(error);
  }
};
