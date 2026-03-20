import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const paramsSchema = z.object({
  categoryId: z.uuid('Invalid categoryId'),
});

const createCategorySchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Category name is required.')
    .max(100, 'Category name must not exceed 100 characters.'),
  description: z
    .string()
    .trim()
    .max(255, 'Description must not exceed 255 characters.')
    .nullable()
    .optional(),
});

const updateCategorySchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, 'Category name must not be empty.')
      .max(100, 'Category name must not exceed 100 characters.')
      .optional(),
    description: z
      .string()
      .trim()
      .max(255, 'Description must not exceed 255 characters.')
      .nullable()
      .optional(),
  })
  .refine(
    (value) => value.name !== undefined || value.description !== undefined,
    {
      message: 'At least one field must be provided for update.',
    },
  );

export const validateCreateCategory = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createCategorySchema, req.body);
  next();
};

export const validateUpdateCategory = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  req.body = validateSchema(updateCategorySchema, req.body);
  next();
};
