import type {StoreMember} from '../types/store.type.js';

export type StoreMembershipResponseDto = Omit<StoreMember, 'joinedAt'>;
