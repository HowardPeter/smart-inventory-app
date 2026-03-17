import type { Request } from 'express';

export type CurrentUser = {
  userId: string;
  authUserId: string | null;
  email: string | null;
};

export type StoreContext = {
  storeId: string;
  role: 'manager' | 'staff';
};

export type AuthenticatedRequest = Request & {
  user: CurrentUser;
};

export type AuthorizedRequest = Request & {
  user: CurrentUser;
  storeContext: StoreContext;
};
