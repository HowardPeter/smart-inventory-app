import { z } from 'zod';

export const createCategorySchema = z.object({
  name: z
    .string()
    .min(1, 'Category name is required')
    .max(100, 'Category name too long'),

  description: z.string().max(500, 'Description too long').optional(),

  storeId: z.string().uuid('Invalid storeId').optional(),
});

export const updateCategorySchema = z.object({
  name: z.string().min(1, 'Category name is required').max(100).optional(),

  description: z.string().max(500).nullable().optional(),
});

export const getCategoriesSchema = z.object({
  keyword: z.string().optional(),

  page: z.string().regex(/^\d+$/).transform(Number).optional(),

  limit: z.string().regex(/^\d+$/).transform(Number).optional(),
});

export const categoryIdParamSchema = z.object({
  categoryId: z.string().uuid('Invalid categoryId'),
});
