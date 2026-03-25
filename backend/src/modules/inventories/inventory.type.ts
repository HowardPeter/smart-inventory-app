/* Định nghĩa các kiểu dữ liệu gốc (Domain Types) cho module Inventory.
Mô phỏng chính xác cấu trúc dữ liệu từ cơ sở dữ liệu
(Prisma) hoặc các nghiệp vụ cốt lõi.
Đây là nền tảng base để dẫn xuất ra các DTO
(sử dụng Pick, Omit, Partial,...) nhằm tránh lặp code. */

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

// NOTE: Cấu trúc Snapshot đại diện cho dữ liệu đã được
// làm phẳng (flatten) từ các bảng liên kết
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
