import { StatusCodes } from 'http-status-codes';
import { z } from 'zod';

import { CustomError } from '../../common/errors/index.js';

import type { NextFunction, Request, Response } from 'express';

const paramsSchema = z.object({
  productId: z.uuid('Invalid productId'),
});

const createProductBodySchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Tên sản phẩm không được để trống')
    .max(255, 'Tên sản phẩm không được vượt quá 255 ký tự'),
  imageUrl: z
    .string()
    .trim()
    .url('Invalid imageUrl')
    .nullable()
    .optional(),
  brand: z
    .string()
    .trim()
    .max(255, 'Brand không được vượt quá 255 ký tự')
    .nullable()
    .optional(),
  categoryId: z.uuid('Invalid categoryId'),
});

const updateProductBodySchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, 'Product name cannot be empty')
      .max(255, 'Product name cannot be exeeded 255 characters')
      .optional(),
    imageUrl: z
      .string()
      .trim()
      .url('Invalid imageUrl')
      .nullable()
      .optional(),
    brand: z
      .string()
      .trim()
      .max(255, 'Brand name cannot be exeeded 255 characters')
      .nullable()
      .optional(),
    categoryId: z.uuid('categoryId').optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

const validateSchema = <T>(schema: z.ZodSchema<T>, data: unknown): T => {
  const result = schema.safeParse(data);

  if (!result.success) {
    throw new CustomError({
      message: result.error.issues[0]?.message ?? 'Invalid data',
      status: StatusCodes.BAD_REQUEST,
    });
  }

  return result.data;
};

export const validateCreateProduct = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createProductBodySchema, req.body);
  next();
};

export const validateUpdateProduct = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  req.body = validateSchema(updateProductBodySchema, req.body);
  next();
};

export const validateGetProductById = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  next();
};

export const validateDeleteProduct = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  next();
};
