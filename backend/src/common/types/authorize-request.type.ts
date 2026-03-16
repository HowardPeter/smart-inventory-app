import type { Request } from 'express';

export type AuthorizedRequest = Request & {
  user: {
    userId: string;
    authUserId: string | null;
    email: string | null;
  };
  storeContext: {
    storeId: string;
    role: 'manager' | 'staff';
  };
};
