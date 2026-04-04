import type { StoreMember } from '../types/store.type.js';

export type StoreMembershipList = Pick<StoreMember, 'userId' | 'storeId'>;

export type StoreMembershipResponseDto = Omit<StoreMember, 'joinedAt'>;

export type CreateStoreMembershipDto = Omit<
  StoreMember,
  'joinedAt' | 'activeStatus'
>;
