import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const createImportTransactionBodySchema = z
  .object({
    note: z.string().trim().max(1000).nullable().optional(),
    items: z
      .array(
        z.object({
          productPackageId: z.uuid('Invalid productPackageId'),
          quantity: z.coerce
            .number()
            .int()
            .positive('Quantity must be greater than 0'),
          unitPrice: z.coerce
            .number()
            .min(0, 'Unit price must be greater than or equal to 0'),
        }),
      )
      .min(1, 'Items cannot be empty'),
  })
  .superRefine((data, ctx) => {
    const productPackageIds = new Set<string>();

    data.items.forEach((item, index) => {
      if (productPackageIds.has(item.productPackageId)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: 'Duplicate productPackageId in transaction items',
          path: ['items', index, 'productPackageId'],
        });
      }

      productPackageIds.add(item.productPackageId);
    });
  });

export const validateCreateImportTransaction = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createImportTransactionBodySchema, req.body);
  next();
};
