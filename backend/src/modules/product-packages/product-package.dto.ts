import type { ProductPackage, Unit } from './product-package.type.js';
import type { Product } from '../products/index.js';

export type UnitResponseDto = Unit;

export type ProductPackageResponseDto = Omit<
  ProductPackage,
  'unitId' | 'productId'
> & {
  unit: Unit;
  product: Pick<Product, 'productId' | 'name' | 'storeId'>;
};

export type CreateProductPackageDto = Pick<ProductPackage, 'unitId'> &
  Partial<
    Pick<
      ProductPackage,
      'importPrice' | 'sellingPrice' | 'barcodeValue' | 'barcodeType'
    >
  >;

export type CreateProductPackageData = CreateProductPackageDto & {
  productId: string;
  displayName: string;
};

export type UpdateProductPackageDto = Partial<
  Pick<
    ProductPackage,
    | 'displayName'
    | 'importPrice'
    | 'sellingPrice'
    | 'barcodeValue'
    | 'barcodeType'
  >
>;
