import 'dotenv/config';
import { StatusCodes } from 'http-status-codes';

import { ProductRepository } from './product.repository.js';
import { CustomError } from '../../common/errors/index.js';
import { StorageService } from '../../common/services/storage.service.js';
import {
  normalizePagination,
  buildPaginatedResponse,
  buildAuditDiff,
} from '../../common/utils/index.js';
import { prisma } from '../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { AuditLogRepository } from '../audit-log/index.js';
import { categoryRepository } from '../categories/index.js';
import { ProductPackageRepository } from '../product-packages/index.js';

import type {
  CreateProductData,
  ProductResponseDto,
  DetailProductResponseDto,
  ProductSimpleResponseDto,
  UpdateProductDto,
  ListProductsQueryDto,
  ListProductsResponseDto,
  ProductsByCategoryDto,
} from './product.dto.js';
import type { DbClient } from '../../common/types/db.type.js';
import type { Prisma } from '../../generated/prisma/client.js';

// Khai báo tên bucket dạng hằng số để dễ quản lý và tái sử dụng
const STORAGE_BUCKET = 'images';

export class ProductService {
  constructor(private readonly productRepository: ProductRepository) {}

  createTxRepositories = (db: DbClient) => ({
    productRepositoryTx: new ProductRepository(db),
    productPackageRepositoryTx: new ProductPackageRepository(db),
    auditLogRepositoryTx: new AuditLogRepository(db),
  });

  private async checkProductExisted(
    storeId: string,
    productId: string,
  ): Promise<ProductSimpleResponseDto | null> {
    const existingProduct = await this.productRepository.findOne(
      storeId,
      productId,
    );

    if (!existingProduct) {
      throw new CustomError({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return {
      categoryId: existingProduct.productId,
      productId: existingProduct.productId,
      name: existingProduct.name,
      imageUrl: existingProduct.imageUrl,
      brand: existingProduct.brand,
      storeId: existingProduct.storeId,
    };
  }

  private async checkCategoryExisted(categoryId: string): Promise<void> {
    const category = await categoryRepository.findById(categoryId);

    if (!category) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }
  }

  async getProductsbyStoreId(
    storeId: string,
    query: ListProductsQueryDto,
  ): Promise<ListProductsResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.productRepository.findManyByStoreId(storeId, {
        ...query,
        ...normalizedPagination,
      });

    // Tạo Signed URL cho danh sách sản phẩm
    const itemsWithSignedUrls = await Promise.all(
      items.map(async (item) => ({
        ...item,
        imageUrl: await StorageService.getSignedUrl(
          STORAGE_BUCKET,
          item.imageUrl,
        ),
      })),
    );

    // FIX: Trả về itemsWithSignedUrls thay vì items gốc từ DB
    return buildPaginatedResponse(
      itemsWithSignedUrls, // Đã sửa
      totalItems,
      normalizedPagination,
    );
  }

  async getProductById(
    storeId: string,
    productId: string,
  ): Promise<DetailProductResponseDto> {
    const product = await this.productRepository.findOne(storeId, productId);

    if (!product) {
      throw new CustomError({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // Tạo Signed URL cho chi tiết sản phẩm
    product.imageUrl = await StorageService.getSignedUrl(
      STORAGE_BUCKET,
      product.imageUrl,
    );

    return product;
  }

  async getProductsByCategory(
    categoryId: string,
  ): Promise<ProductsByCategoryDto> {
    await this.checkCategoryExisted(categoryId);

    const result =
      await this.productRepository.findProductsByCategoryId(categoryId);

    // Tạo Signed URL cho mảng products trong category
    const productsWithSignedUrls = await Promise.all(
      result.products.map(async (p) => ({
        ...p,
        imageUrl: await StorageService.getSignedUrl(STORAGE_BUCKET, p.imageUrl),
      })),
    );

    return {
      count: result.count,
      products: productsWithSignedUrls,
    };
  }

  async getActiveProductsByIds(
    storeId: string,
    productIds: string[],
  ): Promise<Array<{ productId: string; name: string }>> {
    return await this.productRepository.findManyActiveByIds(
      storeId,
      productIds,
    );
  }

  async createProduct(
    storeId: string,
    userId: string,
    data: CreateProductData,
  ): Promise<ProductResponseDto> {
    await this.checkCategoryExisted(data.categoryId);

    const newProduct = await prisma.$transaction(async (tx) => {
      const { productRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const newProduct = await productRepositoryTx.createOne(data);

      await auditLogRepositoryTx.createLog({
        actionType: 'create',
        entityType: 'Product',
        userId,
        storeId,
        oldValue: null,
        newValue: {
          productId: newProduct.productId,
          productName: newProduct.name,
          brand: newProduct.brand,
          category: newProduct.category,
        } as Prisma.InputJsonObject,
      });

      return newProduct;
    });

    // Trả về kèm Signed URL ngay sau khi tạo thành công để UI hiển thị luôn
    newProduct.imageUrl = await StorageService.getSignedUrl(
      STORAGE_BUCKET,
      newProduct.imageUrl,
    );

    return newProduct;
  }

  async updateProduct(
    storeId: string,
    userId: string,
    productId: string,
    data: UpdateProductDto,
  ): Promise<ProductResponseDto> {
    const existingProduct = await this.checkProductExisted(storeId, productId);

    if (data.categoryId) {
      await this.checkCategoryExisted(data.categoryId);
    }

    const { oldValue, newValue } = buildAuditDiff(
      {
        categoryId: existingProduct?.categoryId,
        name: existingProduct?.name,
        imageUrl: existingProduct?.imageUrl,
        brand: existingProduct?.brand,
      },
      data,
    );

    const updatedProduct = await prisma.$transaction(async (tx) => {
      const { productRepositoryTx, auditLogRepositoryTx } =
        this.createTxRepositories(tx);

      const product = await productRepositoryTx.updateOne(productId, data);

      // chỉ log khi có thay đổi thực sự
      if (Object.keys(newValue).length > 0) {
        await auditLogRepositoryTx.createLog({
          actionType: 'update',
          entityType: 'Product',
          userId,
          storeId,
          note: null,
          oldValue: oldValue as Prisma.InputJsonObject,
          newValue: newValue as Prisma.InputJsonObject,
        });
      }

      return product;
    });

    // Trả về kèm Signed URL sau khi update
    updatedProduct.imageUrl = await StorageService.getSignedUrl(
      STORAGE_BUCKET,
      updatedProduct.imageUrl,
    );

    return updatedProduct;
  }

  async softDeleteProduct(
    storeId: string,
    userId: string,
    productId: string,
  ): Promise<void> {
    await this.checkProductExisted(storeId, productId);

    await prisma.$transaction(async (tx) => {
      const {
        productRepositoryTx,
        auditLogRepositoryTx,
        productPackageRepositoryTx,
      } = this.createTxRepositories(tx);

      const softDeletedProduct =
        await productRepositoryTx.softDeleteOne(productId);

      await auditLogRepositoryTx.createLog({
        actionType: 'delete',
        entityType: 'Product',
        userId,
        storeId,
        note: null,
        oldValue: {
          productId: softDeletedProduct.productId,
          activeStatus: 'active',
        } as Prisma.InputJsonObject,
        newValue: {
          productId: softDeletedProduct.productId,
          activeStatus: 'inactive',
        } as Prisma.InputJsonObject,
      });

      await productPackageRepositoryTx.softDeleteManyByProductId(productId);
    });
  }
}
