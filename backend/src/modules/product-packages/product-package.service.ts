import { StatusCodes } from 'http-status-codes';

import { ProductPackageRepository } from './repositories/product-package.repository.js';
import { UnitRepository } from './repositories/unit.repository.js';
import { CustomError } from '../../common/errors/index.js';
import { prisma } from '../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { InventoryRepository } from '../inventories/index.js';
import { productService } from '../products/index.js';

import type {
  CreateProductPackageData,
  CreateProductPackageDto,
  ProductPackageResponseDto,
  UpdateProductPackageDto,
} from './product-package.dto.js';

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

  async createProductPackage(
    storeId: string,
    productId: string,
    data: CreateProductPackageDto,
  ): Promise<ProductPackageResponseDto> {
    const product = await productService.getProductById(storeId, productId);
    const unit = await this.unitRepository.findUnitById(data.unitId);

    if (!unit) {
      throw new CustomError({
        message: 'Unit not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const existingPackageSameUnit =
      await this.productPackageRepository.findActiveByProductIdAndUnitId(
        productId,
        data.unitId,
      );

    if (existingPackageSameUnit) {
      throw new CustomError({
        message:
          'This product already has an active package with the same unit',
        status: StatusCodes.CONFLICT,
      });
    }

    if (data.barcodeValue) {
      const existingPackageSameBarcode =
        await this.productPackageRepository.findActiveByBarcodeValueInStore(
          storeId,
          data.barcodeValue,
        );

      if (existingPackageSameBarcode) {
        throw new CustomError({
          message: 'Barcode already exists',
          status: StatusCodes.CONFLICT,
        });
      }
    }

    // tạo tên package tự động, vd: Coca Cola Zero Sugar thùng
    const createData: CreateProductPackageData = {
      ...data,
      productId,
      displayName: `${product.name} ${unit.name}`.trim(),
    };

    return await this.productPackageRepository.createOne(createData);
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
