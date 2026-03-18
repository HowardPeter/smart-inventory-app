import type { Store, StoreMember } from '../types/store.type.js';

export type StoreResponseDto = Store;

// trả về dữ liệu raw (dùng cho repository)
export type ListRawStoreDto = Store & {
  storeMembers: Array<Pick<StoreMember, 'role'>> // trả mảng vì schema chỉ định StoreMember[]
};

// trả về dữ liệu clean (dùng cho service)
export type ListStoreResponseDto = Store & Pick<StoreMember, 'role'>;

export type CreateStoreDto = Pick<Store, 'name' | 'address' | 'timezone' | 'userId'>;

export type UpdateStoreDto = Partial<Pick<Store, 'name' | 'address' | 'timezone'>>;
