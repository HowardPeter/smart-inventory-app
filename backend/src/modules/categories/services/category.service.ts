import { CategoryRepository } from '../repositories/category.repository.js';

import type { CreateCategoryDTO } from '../dtos/create-category.dto.js';
import type { GetCategoriesDTO } from '../dtos/get-category.dto.js';
import type { UpdateCategoryDTO } from '../dtos/update-category.dto.js';

export class CategoryService {
  private categoryRepository = new CategoryRepository();

  async createCategory(data: CreateCategoryDTO) {
    const existed = await this.categoryRepository.findByName(
      data.name,
      data.storeId,
    );

    if (existed) {
      throw new Error('Category already exists');
    }

    const category = await this.categoryRepository.createCategory(data);

    return category;
  }

  async updateCategory(categoryId: string, data: UpdateCategoryDTO) {
    const category = await this.categoryRepository.findById(categoryId);

    if (!category) {
      throw new Error('Category not found');
    }

    return this.categoryRepository.updateCategory(categoryId, data);
  }

  async deleteCategory(categoryId: string) {
    const category = await this.categoryRepository.findById(categoryId);

    if (!category) {
      throw new Error('Category not found');
    }

    if (category.isDefault) {
      throw new Error('Default category cannot be deleted');
    }

    const productCount =
      await this.categoryRepository.countProducts(categoryId);

    if (productCount > 0) {
      throw new Error('Category cannot be deleted because it has products');
    }

    await this.categoryRepository.deleteCategory(categoryId);
  }

  async getCategories(query: GetCategoriesDTO) {
    return this.categoryRepository.getCategories(query);
  }
}
