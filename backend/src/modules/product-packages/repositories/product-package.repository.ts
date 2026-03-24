import { prisma } from '../../../db/prismaClient.js';

import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  CreateProductPackageData,
  ProductPackageResponseDto,
  UpdateProductPackageDto,
} from '../product-package.dto.js';

const productPackageResponseSelect = {
  productPackageId: true,
  displayName: true,
  importPrice: true,
  sellingPrice: true,
  activeStatus: true,
  barcodeValue: true,
  barcodeType: true,
  createdAt: true,
  updatedAt: true,
  unit: {
    select: {
      unitId: true,
      code: true,
      name: true,
    },
  },
  product: {
    select: {
      productId: true,
      name: true,
      storeId: true,
    },
  },
} satisfies Prisma.ProductPackageSelect;

type ProductPackageRecord = Prisma.ProductPackageGetPayload<{
  select: typeof productPackageResponseSelect;
}>;

export class ProductPackageRepository {
  // convert importPrice, sellingPrice từ Prisma Decimal sang number | null.
  private toResponseDto(
    productPackage: ProductPackageRecord,
  ): ProductPackageResponseDto {
    return {
      ...productPackage,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
    };
  }

  async findManyByProductId(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageResponseDto[]> {
    const productPackages = await prisma.productPackage.findMany({
      where: {
        productId,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      select: productPackageResponseSelect,
    });

    return productPackages.map((productPackage) =>
      this.toResponseDto(productPackage),
    );
  }

  async findOne(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageResponseDto | null> {
    const productPackage = await prisma.productPackage.findFirst({
      where: {
        productPackageId,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      select: productPackageResponseSelect,
    });

    return productPackage ? this.toResponseDto(productPackage) : null;
  }

  async findActiveByProductIdAndUnitId(
    productId: string,
    unitId: string,
  ): Promise<{ productPackageId: string } | null> {
    return prisma.productPackage.findFirst({
      where: {
        productId,
        unitId,
        activeStatus: 'active',
      },
      select: {
        productPackageId: true,
      },
    });
  }

  async findActiveByBarcodeValueInStore(
    storeId: string,
    barcodeValue: string,
  ): Promise<{ productPackageId: string } | null> {
    return prisma.productPackage.findFirst({
      where: {
        barcodeValue,
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      select: {
        productPackageId: true,
      },
    });
  }

  async createOne(
    data: CreateProductPackageData,
  ): Promise<ProductPackageResponseDto> {
    const productPackage = await prisma.productPackage.create({
      data,
      select: productPackageResponseSelect,
    });

    return this.toResponseDto(productPackage);
  }

  async updateOne(
    productPackageId: string,
    data: UpdateProductPackageDto,
  ): Promise<ProductPackageResponseDto> {
    const productPackage = await prisma.productPackage.update({
      where: { productPackageId },
      data: {
        ...(data.displayName !== undefined && {
          displayName: data.displayName,
        }),
        ...(data.importPrice !== undefined && {
          importPrice: data.importPrice,
        }),
        ...(data.sellingPrice !== undefined && {
          sellingPrice: data.sellingPrice,
        }),
        ...(data.barcodeValue !== undefined && {
          barcodeValue: data.barcodeValue,
        }),
        ...(data.barcodeType !== undefined && {
          barcodeType: data.barcodeType,
        }),
      },
      select: productPackageResponseSelect,
    });

    return this.toResponseDto(productPackage);
  }

  async softDeleteOne(productPackageId: string): Promise<void> {
    await prisma.productPackage.update({
      where: { productPackageId },
      data: {
        activeStatus: 'inactive',
      },
    });
  }
}
