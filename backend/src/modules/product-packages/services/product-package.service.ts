import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/index.js';
import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { prisma } from '../../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { AuditLogRepository } from '../../audit-log/index.js';
import { InventoryRepository } from '../../inventories/index.js';
import { productService } from '../../products/index.js';
import { ProductPackageRepository } from '../repositories/product-package.repository.js';
import { UnitRepository } from '../repositories/unit.repository.js';

import type { Prisma } from '../../../generated/prisma/client.js';
import type {
  CreateProductPackageData,
  CreateInventoryData,
  CreateProductPackageAndInventoryDto,
  ListProductPackagesResponseDto,
  PackageQueryDto,
  ProductPackageResponseDto,
  UpdateProductPackageDto,
  ProductPackageResponseForTransaction,
} from '../product-package.dto.js';

export class ProductPackageService {
  constructor(
    private readonly productPackageRepository: ProductPackageRepository,
    private readonly unitRepository: UnitRepository,
  ) {}

  private async checkProductPackageExisted(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageResponseDto> {
    const existingProductPackage = await this.productPackageRepository.findOne(
      storeId,
      productPackageId,
    );

    if (!existingProductPackage) {
      throw new CustomError({
        message: 'Product package not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return existingProductPackage;
  }

  async getProductPackagesByStore(
    storeId: string,
    query: PackageQueryDto,
  ): Promise<ListProductPackagesResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.productPackageRepository.findManyByStore(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async getProductPackagesByProductId(
    storeId: string,
    productId: string,
  ): Promise<ProductPackageResponseDto[]> {
    await productService.getProductById(storeId, productId);

    return await this.productPackageRepository.findManyByProductId(
      storeId,
      productId,
    );
  }

  async getProductPackageById(
    storeId: string,
    productPackageId: string,
  ): Promise<ProductPackageResponseDto> {
    return await this.checkProductPackageExisted(storeId, productPackageId);
  }

  async getProductPackagesByIds(
    storeId: string,
    productPackageIds: string[],
  ): Promise<ProductPackageResponseForTransaction[]> {
    return await this.productPackageRepository.findManyActiveByIds(
      storeId,
      productPackageIds,
    );
  }

  async getProductIdsHavingPackages(
    storeId: string,
    productIds: string[],
  ): Promise<string[]> {
    return await this.productPackageRepository
      .findProductIdsHavingActivePackages(
        storeId,
        productIds,
      );
  }

  async createProductPackage(
    storeId: string,
    userId: string,
    productId: string,
    data: CreateProductPackageAndInventoryDto,
  ): Promise<ProductPackageResponseDto> {
    const product = await productService.getProductById(storeId, productId);
    const unit = await this.unitRepository.findUnitById(data.package.unitId);

    if (!unit) {
      throw new CustomError({
        message: 'Unit not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (data.package.barcodeValue) {
      const existingPackageSameBarcode =
        await this.productPackageRepository.findActiveByBarcodeValueInStore(
          storeId,
          data.package.barcodeValue,
        );

      if (existingPackageSameBarcode) {
        throw new CustomError({
          message: 'Barcode already exists',
          status: StatusCodes.CONFLICT,
        });
      }
    }

    // tạo tên package tự động, vd: Coca Cola Zero Sugar thùng
    const createPackageData: CreateProductPackageData = {
      ...data.package,
      productId,
      displayName: `${product.name} ${unit.name}`.trim(),
    };

    const createInventoryData: CreateInventoryData = {
      ...data.inventory,
    };

    return await prisma.$transaction(async (tx) => {
      const productPackageRepositoryTx = new ProductPackageRepository(tx);
      const auditLogRepositoryTx = new AuditLogRepository(tx);

      const createdProductPackage = await productPackageRepositoryTx.createOne(
        createPackageData,
        createInventoryData,
      );

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'ProductPackage',
        userId,
        storeId,
        oldValue: null,
        newValue: {
          productPackageId: createdProductPackage.productPackageId,
          productId: createdProductPackage.product.productId,
          displayName: createdProductPackage.displayName,
          unitId: createdProductPackage.unit.unitId,
          importPrice: createdProductPackage.importPrice,
          sellingPrice: createdProductPackage.sellingPrice,
          barcodeValue: createdProductPackage.barcodeValue,
          barcodeType: createdProductPackage.barcodeType,
        } as Prisma.InputJsonObject,
      });

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Inventory',
        userId,
        storeId,
        oldValue: null,
        newValue: {
          inventoryId: createdProductPackage.inventory?.inventoryId,
          quantity: createdProductPackage.inventory?.quantity,
          reorderThreshold: createdProductPackage.inventory?.reorderThreshold,
          productPackageId: createdProductPackage.productPackageId,
        } as Prisma.InputJsonObject,
      });

      return createdProductPackage;
    });
  }

  async updateProductPackage(
    storeId: string,
    productPackageId: string,
    data: UpdateProductPackageDto,
  ): Promise<ProductPackageResponseDto> {
    const existingProductPackage = await this.checkProductPackageExisted(
      storeId,
      productPackageId,
    );

    if (data.barcodeValue) {
      const existingPackageSameBarcode =
        await this.productPackageRepository.findActiveByBarcodeValueInStore(
          storeId,
          data.barcodeValue,
        );

      if (
        existingPackageSameBarcode &&
        existingPackageSameBarcode.productPackageId !== productPackageId
      ) {
        throw new CustomError({
          message: 'Barcode already exists',
          status: StatusCodes.CONFLICT,
        });
      }
    }

    if (
      data.barcodeType !== undefined &&
      data.barcodeType !== null &&
      !((data.barcodeValue ?? existingProductPackage.barcodeValue) !== null)
    ) {
      throw new CustomError({
        message: 'barcodeType requires barcodeValue',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    if (
      data.barcodeValue !== undefined &&
      data.barcodeValue === null &&
      data.barcodeType === undefined
    ) {
      data.barcodeType = null;
    }

    if (data.displayName !== undefined) {
      data.displayName = data.displayName?.trim() || null;
    }

    return await this.productPackageRepository.updateOne(
      productPackageId,
      data,
    );
  }

  async softDeleteProductPackage(
    storeId: string,
    productPackageId: string,
  ): Promise<void> {
    await this.checkProductPackageExisted(storeId, productPackageId);

    // xóa inventory tương ứng khi xóa product package
    await prisma.$transaction(async (tx) => {
      const productPackageRepositoryTx = new ProductPackageRepository(tx);
      const inventoryRepositoryTx = new InventoryRepository(tx);

      await productPackageRepositoryTx.softDeleteOne(productPackageId);

      await inventoryRepositoryTx.softDeleteOneByPackageId(productPackageId);
    });
  }
}
