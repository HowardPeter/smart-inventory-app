import { z } from 'zod';

export const removeStoreMemberSchema = z.object({
  params: z.object({
    userId: z.string().uuid(),
  }),
});
