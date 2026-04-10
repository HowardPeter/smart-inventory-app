import { TransactionRepository } from './repositories/transaction.repository.js';
import { TransactionController } from './transaction.controller.js';
import { TransactionService } from './transaction.service.js';
import { prisma } from '../../db/prismaClient.js';
import { inventoryService } from '../inventories/index.js';
import { productPackageService } from '../product-packages/index.js';

const transactionRepository = new TransactionRepository(prisma);
const transactionService = new TransactionService(
  transactionRepository,
  productPackageService,
  inventoryService,
);
const transactionController = new TransactionController(transactionService);

export { transactionService, transactionController };
