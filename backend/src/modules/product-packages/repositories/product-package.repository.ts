import { getPaginationSkip } from '../../../common/utils/index.js';

import type {
  DbClient,
  ListPaginationResponseDto,
} from '../../../common/types/index.js';
import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  CreateProductPackageData,
  PackageQueryDto,
  ProductPackageResponseDto,
  UpdateProductPackageDto,
  ProductPackageSimpleResponseDto,
  ProductPackageResponseForTransaction,
  CreateInventoryData,
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
      category: {
        select: {
          categoryId: true,
          name: true,
        },
      },
    },
  },
  inventory: {
    select: {
      inventoryId: true,
      quantity: true,
      reorderThreshold: true,
    },
  },
} satisfies Prisma.ProductPackageSelect;

type ProductPackageRecord = Prisma.ProductPackageGetPayload<{
  select: typeof productPackageResponseSelect;
}>;

export class ProductPackageRepository {
  constructor(private readonly db: DbClient) {}

  // convert importPrice, sellingPrice từ Prisma Decimal sang number | null.
  private toResponseDto(
    productPackage: ProductPackageRecord,
  ): ProductPackageResponseDto {
    return {
      productPackageId: productPackage.productPackageId,
      displayName: productPackage.displayName,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
      activeStatus: productPackage.activeStatus,
      barcodeValue: productPackage.barcodeValue,
      barcodeType: productPackage.barcodeType,
      createdAt: productPackage.createdAt,
      updatedAt: productPackage.updatedAt,
      unit: productPackage.unit,
      category: productPackage.product.category,
      product: {
        productId: productPackage.product.productId,
        name: productPackage.product.name,
        storeId: productPackage.product.storeId,
      },
      inventory: productPackage.inventory,
    };
  }

  async findManyByStore(
    storeId: string,
    query: PackageQueryDto,
  ): Promise<ListPaginationResponseDto<ProductPackageResponseDto>> {
    const { page, limit, categoryId, sortBy, sortOrder } = query;

    const where: Prisma.ProductPackageWhereInput = {
      activeStatus: 'active',
      product: {
        storeId,
        activeStatus: 'active',
        ...(categoryId ? { categoryId } : {}),
      },
    };

    const [productPackages, totalItems] = await this.db.$transaction([
      this.db.productPackage.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: productPackageResponseSelect,
      }),
      this.db.productPackage.count({
        where,
      }),
    ]);

    const items = productPackages.map((productPackage) =>
      this.toResponseDto(productPackage),
    );

    return {
      items,
      totalItems,
    };
  }

  async findManyByProductId(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageResponseDto[]> {
    const productPackages = await this.db.productPackage.findMany({
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

  async findManyByProductIdForNameSync(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageSimpleResponseDto[]> {
    return await this.db.productPackage.findMany({
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
      select: {
        productPackageId: true,
        displayName: true,
      },
    });
  }

  async findOne(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageResponseDto | null> {
    const productPackage = await this.db.productPackage.findFirst({
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

  async findManyActiveByIds(
    storeId: string,
    productPackageIds: string[],
  ): Promise<ProductPackageResponseForTransaction[]> {
    if (productPackageIds.length === 0) {
      return [];
    }

    const productPackages = await this.db.productPackage.findMany({
      where: {
        productPackageId: {
          in: productPackageIds,
        },
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      select: {
        productPackageId: true,
        displayName: true,
        importPrice: true,
        sellingPrice: true,
      },
    });

    return productPackages.map((productPackage) => ({
      productPackageId: productPackage.productPackageId,
      displayName: productPackage.displayName,
      importPrice: productPackage.importPrice?.toNumber() ?? null,
      sellingPrice: productPackage.sellingPrice?.toNumber() ?? null,
    }));
  }

  async findProductIdsHavingActivePackages(
    storeId: string,
    productIds: string[],
  ): Promise<string[]> {
    if (productIds.length === 0) {
      return [];
    }

    const productPackages = await this.db.productPackage.findMany({
      where: {
        productId: {
          in: productIds,
        },
        activeStatus: 'active',
        product: {
          storeId,
          activeStatus: 'active',
        },
      },
      distinct: ['productId'],
      select: {
        productId: true,
      },
    });

    return productPackages.map((productPackage) => productPackage.productId);
  }

  async findActiveByProductIdAndUnitId(
    productId: string,
    unitId: string,
  ): Promise<{ productPackageId: string } | null> {
    return this.db.productPackage.findFirst({
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
    return this.db.productPackage.findFirst({
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

  async createOneAndInventory(
    packageData: CreateProductPackageData,
    inventoryData: CreateInventoryData,
  ): Promise<ProductPackageResponseDto> {
    const productPackage = await this.db.productPackage.create({
      data: {
        ...packageData,
        inventory: {
          create: inventoryData,
        },
      },
      select: productPackageResponseSelect,
    });

    return this.toResponseDto(productPackage);
  }

  async updateOne(
    productPackageId: string,
    data: UpdateProductPackageDto,
  ): Promise<ProductPackageResponseDto> {
    const productPackage = await this.db.productPackage.update({
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

  async updateDisplayNameWithProduct(
    productPackageId: string,
    newDisplayName: string,
  ): Promise<ProductPackageSimpleResponseDto> {
    return await this.db.productPackage.update({
      where: { productPackageId },
      data: {
        displayName: newDisplayName,
      },
      select: {
        productPackageId: true,
        displayName: true,
      },
    });
  }

  async softDeleteOne(
    productPackageId: string,
  ): Promise<{ productPackageId: string }> {
    return await this.db.productPackage.update({
      where: { productPackageId },
      data: {
        activeStatus: 'inactive',
      },
      select: {
        productPackageId: true,
      },
    });
  }

  async softDeleteManyByProductId(productId: string): Promise<number> {
    const deleted = await this.db.productPackage.updateMany({
      where: { productId },
      data: {
        activeStatus: 'inactive',
      },
    });

    return deleted.count;
  }
}
