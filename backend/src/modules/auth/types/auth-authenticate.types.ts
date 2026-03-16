import type { Request } from 'express';

export type CurrentUser = {
  userId: string;
  authUserId: string | null;
  email: string | null;
};

export type AuthenticatedRequest = Request & {
  user: CurrentUser;
};
