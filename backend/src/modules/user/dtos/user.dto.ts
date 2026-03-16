import type { UserProfile } from '../types/user.type.js';

export type UserProfileAuthDTO = Omit<UserProfile, 'createdAt' | 'updatedAt'>;
