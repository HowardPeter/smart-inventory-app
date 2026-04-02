import { TransactionController } from './transaction.controller.js';
import { TransactionService } from './transaction.service.js';
import { inventoryService } from '../inventories/index.js';
import { productPackageService } from '../product-packages/index.js';
import { productService } from '../products/index.js';

const transactionService = new TransactionService(
  productService,
  productPackageService,
  inventoryService,
);
const transactionController = new TransactionController(transactionService);

export { transactionService, transactionController };
