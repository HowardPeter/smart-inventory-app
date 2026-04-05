import { z } from 'zod';

export const removeStoreMemberSchema = z.object({
  params: z.object({
    userId: z.string().uuid(),
  }),
});

export const updateStoreMemberRoleSchema = z.object({
  params: z.object({
    userId: z.string().uuid(),
  }),
  body: z.object({
    role: z.enum(['manager', 'staff']),
  }),
});
