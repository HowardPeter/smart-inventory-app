import type { ActiveStatus, StoreRole } from '../../../generated/prisma/enums.js';

export type Store = {
  storeId: string;
  address: string | null;
  timezone: string | null;
  name: string | null;
  createdAt: Date;
  updatedAt: Date;
  activeStatus: ActiveStatus;
  userId: string;
};

export type StoreMember = {
  userId: string;
  storeId: string;
  role: StoreRole;
  joinedAt: Date;
  activeStatus: ActiveStatus;
};
