import type { Request } from 'express';

export type CurrentUser = {
  userId: string;
  authUserId: string;
  email: string;
};

export type AuthenticatedRequest = Request & {
  user: CurrentUser;
};
