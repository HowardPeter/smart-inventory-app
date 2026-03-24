type ActiveStatus = 'active' | 'inactive';
type BarcodeType = 'upc' | 'ean' | 'code128' | 'qr';

export type ProductPackage = {
  productPackageId: string;
  displayName: string | null;
  importPrice: number | null;
  sellingPrice: number | null;
  activeStatus: ActiveStatus;
  barcodeValue: string | null;
  barcodeType: BarcodeType | null;
  createdAt: Date;
  updatedAt: Date;
  unitId: string;
  productId: string;
};

export type Unit = {
  unitId: string;
  code: string;
  name: string;
};
