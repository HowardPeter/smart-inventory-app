import { StatusCodes } from 'http-status-codes';

import { ProductRepository } from './product.repository.js';
import { CustomError } from '../../common/errors/index.js';
import {
  normalizePagination,
  buildPaginatedResponse,
} from '../../common/utils/index.js';
import { CategoryRepository } from '../categories/index.js';

import type {
  CreateProductData,
  ProductResponseDto,
  UpdateProductDto,
  ListProductsQueryDto,
  ListProductsResponseDto,
} from './product.dto.js';

export class ProductService {
  constructor(
    private readonly productRepository: ProductRepository,
    private readonly categoryRepository: CategoryRepository,
  ) {}

  private async checkProductExisted(
    storeId: string,
    productId: string,
  ): Promise<void> {
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

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async getProductById(
    storeId: string,
    productId: string,
  ): Promise<ProductResponseDto> {
    const product = await this.productRepository.findOne(storeId, productId);

    if (!product) {
      throw new CustomError({
        message: 'Product not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return product;
  }

  async createProduct(
    data: CreateProductData,
  ): Promise<ProductResponseDto> {
    const category = await this.categoryRepository.findById(data.categoryId);

    if (!category) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return await this.productRepository.createOne(data);
  }

  async updateProduct(
    storeId: string,
    productId: string,
    data: UpdateProductDto,
  ): Promise<ProductResponseDto> {
    await this.checkProductExisted(storeId, productId);

    if (data.categoryId) {
      const category = await this.categoryRepository.findById(data.categoryId);

      if (!category) {
        throw new CustomError({
          message: 'Category not found',
          status: StatusCodes.NOT_FOUND,
        });
      }
    }

    return await this.productRepository.updateOne(productId, data);
  }

  async softDeleteProduct(storeId: string, productId: string): Promise<void> {
    await this.checkProductExisted(storeId, productId);

    return await this.productRepository.softDeleteOne(productId);
  }
}
