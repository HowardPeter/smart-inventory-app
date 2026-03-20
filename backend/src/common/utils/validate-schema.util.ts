import { StatusCodes } from 'http-status-codes';
import { z } from 'zod';

import { CustomError } from '../../common/errors/index.js';

export const validateSchema = <T>(schema: z.ZodSchema<T>, data: unknown): T => {
  const result = schema.safeParse(data);

  if (!result.success) {
    throw new CustomError({
      message: result.error.issues[0]?.message ?? 'Invalid data',
      status: StatusCodes.BAD_REQUEST,
    });
  }

  return result.data;
};
