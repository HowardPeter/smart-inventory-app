import { ProductController } from './product.controller.js';
import { ProductRepository } from './product.repository.js';
import { ProductService } from './product.service.js';
import { CategoryRepository } from '../categories/index.js';

const productRepository = new ProductRepository();
const categoryRepository = new CategoryRepository();
const productService = new ProductService(
  productRepository,
  categoryRepository,
);
const productController = new ProductController(productService);

export { productService, productController };
