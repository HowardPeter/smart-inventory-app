type ActiveStatus = 'active' | 'inactive';

export type Product = {
  productId: string;
  name: string;
  imageUrl: string | null;
  brand: string | null;
  activeStatus: ActiveStatus;
  createdAt: Date;
  updatedAt: Date;
  storeId: string;
  categoryId: string;
};
