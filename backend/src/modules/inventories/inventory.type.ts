export type InventoryStatus = 'inStock' | 'lowStock' | 'outOfStock';

export type AdjustmentType = 'set' | 'increase' | 'decrease';

export type Inventory = {
  inventoryId: string;
  quantity: number;
  reorderThreshold: number | null;
  lastCount: number | null;
  updatedAt: Date;
  productPackageId: string;
};

export type Unit = {
  unitId: string;
  code: string;
  name: string;
};

export type ProductPackageSnapshot = {
  productPackageId: string;
  displayName: string | null;
  importPrice: number | null;
  sellingPrice: number | null;
  barcodeValue: string | null;
  barcodeType: 'upc' | 'ean' | 'code128' | 'qr' | null;
};

export type ProductSnapshot = {
  productId: string;
  name: string;
  imageUrl: string | null;
  brand: string | null;
  category: {
    categoryId: string;
    name: string;
    description: string | null;
  };
};
