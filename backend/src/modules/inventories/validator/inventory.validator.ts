import { z } from 'zod';

import { validateSchema } from '../../../common/utils/index.js';

import type { Request, Response, NextFunction } from 'express';

const paramsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

const listInventoriesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(10),
  sortBy: z
    .enum(['updatedAt', 'quantity', 'reorderThreshold', 'lastCount'])
    .optional()
    .default('updatedAt'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
  keyword: z.string().trim().min(1).max(255).optional(),
  categoryId: z.string().uuid('Invalid categoryId').optional(),
  inventoryStatus: z.enum(['inStock', 'lowStock', 'outOfStock']).optional(),
});

const updateInventoryBodySchema = z
  .object({
    reorderThreshold: z.number().int().min(0).nullable().optional(),
    lastCount: z.number().int().min(0).nullable().optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

const adjustInventoryBodySchema = z.object({
  type: z.enum(['set', 'increase', 'decrease']),
  quantity: z.number().int().min(0),
  reason: z.string().trim().min(1).max(255).nullable().optional(),
  note: z.string().trim().min(1).max(500).nullable().optional(),
});

const createInventoryBodySchema = z.object({
  productPackageId: z.string().uuid('Invalid productPackageId'),
  quantity: z.number().int().min(0).default(0),
  reorderThreshold: z.number().int().min(0).nullable().optional(),
  lastCount: z.number().int().min(0).nullable().optional(),
});

export const validateGetInventories = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  res.locals.validatedQuery = validateSchema(
    listInventoriesQuerySchema,
    req.query,
  );

  next();
};

export const validateGetLowStockInventories = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  res.locals.validatedQuery = validateSchema(
    listInventoriesQuerySchema,
    req.query,
  );

  next();
};

export const validateGetInventoryByProductPackageId = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);

  next();
};

export const validateUpdateInventory = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  req.body = validateSchema(updateInventoryBodySchema, req.body);

  next();
};

export const validateAdjustInventory = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  req.body = validateSchema(adjustInventoryBodySchema, req.body);

  next();
};

export const validateCreateInventory = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createInventoryBodySchema, req.body);
  next();
};

export const validateDeleteInventory = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  next();
};
