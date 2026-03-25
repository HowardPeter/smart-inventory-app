import { ProductController } from './product.controller.js';
import { ProductRepository } from './product.repository.js';
import { ProductService } from './product.service.js';
import { prisma } from '../../db/prismaClient.js';
import { CategoryRepository } from '../categories/index.js';

const productRepository = new ProductRepository(prisma);
const categoryRepository = new CategoryRepository();
const productService = new ProductService(
  productRepository,
  categoryRepository,
);
const productController = new ProductController(productService);

export { productService, productController };
