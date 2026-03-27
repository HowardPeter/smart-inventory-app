import { StatusCodes } from 'http-status-codes';

import { CategoryRepository } from './repositories/category.repository.js';
import { HiddenDefaultRepository } from './repositories/hidden-default.repository.js';
import { CustomError } from '../../common/errors/index.js';
import { prisma } from '../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { ProductRepository, productService } from '../products/index.js';

import type {
  CategoryResponseDto,
  CreateCategoryDto,
  UpdateCategoryDto,
} from './category.dto.js';

export class CategoriesService {
  constructor(
    private readonly categoryRepository: CategoryRepository,
    private readonly hiddenDefaultRepository: HiddenDefaultRepository,
  ) {}

  public async findAll(storeId: string): Promise<CategoryResponseDto[]> {
    return await this.categoryRepository.findAll(storeId);
  }

  public async createOne(
    storeId: string,
    payload: CreateCategoryDto,
  ): Promise<CategoryResponseDto> {
    return await this.categoryRepository.createOne(storeId, payload);
  }

  public async updateOne(
    storeId: string,
    categoryId: string,
    payload: UpdateCategoryDto,
  ): Promise<CategoryResponseDto> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (foundCategory.isDefault) {
      throw new CustomError({
        message: 'Default category cannot be edited',
        status: StatusCodes.FORBIDDEN,
      });
    }

    if (foundCategory.storeId !== storeId) {
      throw new CustomError({
        message: 'You do not have permission to update this category',
        status: StatusCodes.FORBIDDEN,
      });
    }

    return await this.categoryRepository.updateOne(categoryId, payload);
  }

  async getProductsInCategory(categoryId: string): Promise<void> {
    await productService.getProductsByCategory(categoryId);
  }

  public async softDeleteDefault(
    storeId: string,
    categoryId: string,
  ): Promise<void> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (!foundCategory.isDefault) {
      throw new CustomError({
        message: 'Cannot hide the custom category',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const isVisible = await this.hiddenDefaultRepository.isDefaultOneVisible(
      storeId,
      categoryId,
    );

    if (!isVisible) {
      throw new CustomError({
        message: 'Default category has already been hidden',
        status: StatusCodes.CONFLICT,
      });
    }

    await this.hiddenDefaultRepository.hideOne(storeId, categoryId);
  }

  public async deleteCustomCategory(
    storeId: string,
    categoryId: string,
    canReassignToUncategorized: boolean,
  ): Promise<void> {
    const foundCategory = await this.categoryRepository.findById(categoryId);

    if (!foundCategory) {
      throw new CustomError({
        message: 'Category not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (foundCategory.isDefault) {
      throw new CustomError({
        message: 'Default category cannot be hard deleted',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    if (foundCategory.storeId !== storeId) {
      throw new CustomError({
        message: 'You do not have permission to delete this category',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // Lấy danh sách product đang gắn với category cần xóa để quyết định
    // có thể xóa ngay hay phải yêu cầu FE xác nhận chuyển sang Uncategorized.
    const productsInCategory =
      await productService.getProductsByCategory(categoryId);

    // Nếu category vẫn đang được product sử dụng và FE chưa xác nhận
    // chuyển product sang Uncategorized, backend trả lỗi 409 để FE
    // hiển thị popup xác nhận cho người dùng.
    if (productsInCategory.count > 0 && !canReassignToUncategorized) {
      throw new CustomError({
        message: 'Category is being used by products',
        status: StatusCodes.CONFLICT,
        code: 'CATEGORY_IN_USE',
        details: {
          productCount: productsInCategory.count,
          products: productsInCategory.products,
        },
      });
    }

    // Nếu category không còn product nào sử dụng thì xóa ngay,
    // không cần qua bước chuyển sang Uncategorized.
    if (productsInCategory.count === 0) {
      await this.categoryRepository.deleteCustomCategory(categoryId);

      return;
    }

    const uncategorizedId = await this.categoryRepository.getUncategorizedId();

    await prisma.$transaction(async (tx) => {
      const categoryRepositoryTx = new CategoryRepository(tx);
      const productRepositoryTx = new ProductRepository(tx);

      // Phải cập nhật các product sang Uncategorized trước khi xóa category cũ
      // để tránh lỗi ràng buộc khóa ngoại.
      await productRepositoryTx.uncategorizeMany(
        storeId,
        categoryId,
        uncategorizedId,
      );

      // NOTE: Phải chạy sau khi uncategorize products
      // NOTE: vì cần category tham chiếu đến cho product trước
      await categoryRepositoryTx.deleteCustomCategory(categoryId);
    });
  }
}
