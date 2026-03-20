import type { UserProfile } from '../types/user-profile.type.js';

export type UserProfileResponseDto = UserProfile;

// create profile KHÔNG nhận authUserId từ client
export type CreateUserProfileDto = Pick<UserProfile, 'email' | 'fullName'>;
