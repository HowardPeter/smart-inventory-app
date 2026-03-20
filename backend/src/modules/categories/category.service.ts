import { StatusCodes } from 'http-status-codes';

import { CategoryRepository } from './repositories/category.repository.js';
import { HiddenDefaultRepository } from './repositories/hidden-default.repository.js';
import { CustomError } from '../../common/errors/index.js';

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

    const productCount =
      await this.categoryRepository.countProductsByCategoryId(categoryId);

    if (productCount > 0) {
      throw new CustomError({
        message:
          'Category cannot be deleted because it is being used by products',
        status: StatusCodes.CONFLICT,
      });
    }

    await this.categoryRepository.deleteCustomCategory(categoryId);
  }
}
