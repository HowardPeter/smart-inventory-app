import { CategoryController } from './category.controller.js';
import { CategoriesService } from './category.service.js';
import { CategoryRepository } from './repositories/category.repository.js';
import { HiddenDefaultRepository } from './repositories/hidden-default.repository.js';

const categoryRepository = new CategoryRepository();
const hiddenDefaultRepository = new HiddenDefaultRepository();
const categoryService = new CategoriesService(
  categoryRepository,
  hiddenDefaultRepository,
);
const categoryController = new CategoryController(categoryService);

export { categoryController };
