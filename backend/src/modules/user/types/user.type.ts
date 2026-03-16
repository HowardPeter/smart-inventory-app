// type ActiveStatus = 'active' | 'inactive';

export type UserProfile = {
  userId: string;
  authUserId: string;
  email: string;
  fullName: string;
  activeStatus: string;
  createdAt: Date;
  updatedAt: Date;
};
