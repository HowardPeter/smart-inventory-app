import { z } from 'zod';

export const updateUserProfileSchema = z.object({
  params: z.object({
    userId: z.string().uuid(),
  }),
  body: z.object({
    fullName: z.string().trim().max(255).optional(),
    address: z.string().trim().max(255).optional(),
    phone: z.string().trim().max(20).optional(),
  }),
});
