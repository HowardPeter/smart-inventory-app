import { StatusCodes } from 'http-status-codes';

import { accessControlService } from './access-control.service.js';
import { CustomError } from '../../common/errors/index.js';
import { requireReqStoreContext } from '../../common/utils/index.js';

import type { AppRole, AppPermission } from './app-role-permission.type.js';
import type { Request, NextFunction, Response } from 'express';

export const requirePermission = (permission: AppPermission) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      const storeContext = requireReqStoreContext(req);
      const role = storeContext.role.toUpperCase() as AppRole;

      const isAllowed = accessControlService.hasPermission({
        role,
        permission,
      });

      if (!isAllowed) {
        throw new CustomError({
          message: 'You do not have permission to perform this action',
          status: StatusCodes.FORBIDDEN,
        });
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};
