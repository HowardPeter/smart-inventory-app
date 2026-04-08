import type { ActiveStatus } from '../../../generated/prisma/client.js';

export type UserProfile = {
  userId: string;
  authUserId: string | null;
  email: string | null;
  fullName: string | null;
  phone: string | null;
  address: string | null;
  createdAt: Date;
  updatedAt: Date;
  activeStatus: ActiveStatus;
};
