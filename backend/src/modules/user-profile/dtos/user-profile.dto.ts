import type { UserProfile } from '../types/user-profile.type.js';

export type UserProfileResponseDto = UserProfile;

export type CreateUserProfileDto = Pick<UserProfile, 'email' | 'fullName'>;

export type UpdateUserProfileDto = Partial<
  Pick<UserProfile, 'fullName' | 'address' | 'phone'>
>;
