export type ActiveStatus = 'active' | 'inactive';

export type UserProfile = {
  userId: string;
  authUserId: string | null;
  email: string | null;
  fullName: string | null;
  createdAt: Date;
  updatedAt: Date;
  activeStatus: ActiveStatus;
};
