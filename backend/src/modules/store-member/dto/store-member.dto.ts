import type { StoreRole } from '../../../generated/prisma/enums.js';
import type { StoreMember } from '../../stores/types/store.type.js';

export type StoreMemberResponseDto = StoreMember;

export type UpdateStoreMemberRoleDto = {
  role: StoreRole;
};
