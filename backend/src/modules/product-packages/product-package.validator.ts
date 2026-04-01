import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const productParamsSchema = z.object({
  productId: z.uuid('Invalid productId'),
});

const productPackageParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

const barcodeTypeSchema = z.enum(['upc', 'ean', 'code128', 'qr']);

const createProductPackageBodySchema = z
  .object({
    unitId: z.uuid('Invalid unitId'),
    importPrice: z.coerce
      .number()
      .min(0, 'Import price must be greater than or equal to 0')
      .nullable()
      .optional(),
    sellingPrice: z.coerce
      .number()
      .min(0, 'Selling price must be greater than or equal to 0')
      .nullable()
      .optional(),
    barcodeValue: z
      .string()
      .trim()
      .min(1, 'Barcode value cannot be empty')
      .max(255, 'Barcode value cannot exceed 255 characters')
      .nullable()
      .optional(),
    barcodeType: barcodeTypeSchema.nullable().optional(),
  })
  .superRefine((data, ctx) => {
    if (data.barcodeType && !data.barcodeValue) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'barcodeType requires barcodeValue',
        path: ['barcodeType'],
      });
    }
  });

const updateProductPackageBodySchema = z
  .object({
    displayName: z
      .string()
      .trim()
      .min(1, 'Display name cannot be empty')
      .max(255, 'Display name cannot exceed 255 characters')
      .nullable()
      .optional(),
    importPrice: z.coerce
      .number()
      .min(0, 'Import price must be greater than or equal to 0')
      .nullable()
      .optional(),
    sellingPrice: z.coerce
      .number()
      .min(0, 'Selling price must be greater than or equal to 0')
      .nullable()
      .optional(),
    barcodeValue: z
      .string()
      .trim()
      .min(1, 'Barcode value cannot be empty')
      .max(255, 'Barcode value cannot exceed 255 characters')
      .nullable()
      .optional(),
    barcodeType: barcodeTypeSchema.nullable().optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  )
  .superRefine((data, ctx) => {
    if (data.barcodeType && !('barcodeValue' in data)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'barcodeType requires barcodeValue',
        path: ['barcodeType'],
      });
    }
  });

export const listPackageQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(50),
  sortBy: z
    .enum(['displayName', 'createdAt', 'updatedAt'])
    .optional()
    .default('displayName'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('asc'),
  categoryId: z.string().uuid('Invalid categoryId').optional(),
});

export const validateGetPackagesByStore = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  _res.locals.validatedQuery = validateSchema(
    listPackageQuerySchema,
    req.query,
  );
  next();
};

export const validateCreateProductPackage = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productParamsSchema, req.params);
  req.body = validateSchema(createProductPackageBodySchema, req.body);
  next();
};

export const validateGetProductPackagesByProductId = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productParamsSchema, req.params);
  next();
};

export const validateGetProductPackageById = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productPackageParamsSchema, req.params);
  next();
};

export const validateUpdateProductPackage = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productPackageParamsSchema, req.params);
  req.body = validateSchema(updateProductPackageBodySchema, req.body);
  next();
};

export const validateDeleteProductPackage = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productPackageParamsSchema, req.params);
  next();
};
