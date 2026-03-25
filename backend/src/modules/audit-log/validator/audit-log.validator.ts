import { z } from 'zod';

import { validateSchema } from '../../../common/utils/index.js';

import type { Request, Response, NextFunction } from 'express';

const listAuditLogsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(10),
  sortBy: z.enum(['performedAt']).optional().default('performedAt'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
  entityType: z.string().trim().optional(),
  actionType: z.enum(['create', 'update', 'delete']).optional(),
  userId: z.string().uuid().optional(),
  startDate: z.string().datetime().optional(), // Yêu cầu format ISO 8601
  endDate: z.string().datetime().optional(),
});

export const validateGetAuditLogs = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  res.locals.validatedQuery = validateSchema(
    listAuditLogsQuerySchema,
    req.query,
  );
  next();
};
