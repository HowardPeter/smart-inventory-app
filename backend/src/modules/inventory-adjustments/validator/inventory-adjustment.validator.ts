import { z } from 'zod';

import { validateSchema } from '../../../common/utils/index.js';

import type { Request, Response, NextFunction } from 'express';

const paramsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

const listAdjustmentsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(10),
  sortBy: z.enum(['createdAt']).optional().default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
});

export const validateGetAdjustments = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  res.locals.validatedQuery = validateSchema(
    listAdjustmentsQuerySchema,
    req.query,
  );

  next();
};
