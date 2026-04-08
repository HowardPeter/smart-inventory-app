import type { StoreRole } from '../../../generated/prisma/enums.js';
import type { StoreMember } from '../../stores/types/store.type.js';
import type { UserProfile } from '../../user-profile/types/user-profile.type.js';

export type StoreMemberResponseDto = StoreMember;

export type UpdateStoreMemberRoleDto = {
  role: StoreRole;
};

export type StoreMemberUserResponseDto = Pick<
  UserProfile,
  'userId' | 'email' | 'fullName' | 'phone' | 'address' | 'activeStatus'
> & {
  role: StoreRole;
  joinedAt: Date;
};

export type RawStoreMemberDto = {
  role: StoreRole;
  joinedAt: Date;
  user: UserProfile;
};
