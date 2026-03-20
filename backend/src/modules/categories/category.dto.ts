import type { Category } from './categoty.type.js';

export type CategoryResponseDto = Category;

export type CreateCategoryDto = Pick<Category, 'name' | 'description'>;

export type UpdateCategoryDto = Partial<Pick<Category, 'name' | 'description'>>;
