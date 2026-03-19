import { StatusCodes } from 'http-status-codes';

import { ProductRepository } from './product.repository.js';
import { CustomError } from '../../common/errors/index.js';
import { CategoryRepository } from '../categories/index.js';

import type {
  CreateProductData,
  DetailProductResponseDto,
  UpdateProductDto,
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

  async getAllbyStoreId(storeId: string): Promise<DetailProductResponseDto[]> {
    return await this.productRepository.findManyByStoreId(storeId);
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

    return product;
  }

  async createProduct(
    data: CreateProductData,
  ): Promise<DetailProductResponseDto> {
    const category = await this.categoryRepository.findOne(data.categoryId);

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
  ): Promise<DetailProductResponseDto> {
    await this.checkProductExisted(storeId, productId);

    if (data.categoryId) {
      const category = await this.categoryRepository.findOne(data.categoryId);

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
