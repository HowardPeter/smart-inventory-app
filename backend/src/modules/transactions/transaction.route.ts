import { Router } from 'express';

import { transactionController } from './transaction.module.js';
import { validateCreateImportTransaction, validateCreateExportTransaction } from './transaction.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const transactionRouter = Router();

transactionRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: POST /api/transactions/import
 * Tạo phiếu nhập kho thủ công
 *
 * Body:
 *  - note?: string | null
 *  - items: {
 *      productPackageId: string;
 *      quantity: number;
 *      unitPrice: number;
 *    }[]
 */
transactionRouter.post(
  '/import',
  requirePermission(PERMISSION.INVENTORY_TRANSACTION_CREATE),
  validateCreateImportTransaction,
  asyncWrapper(transactionController.createImportTransaction),
);

/**
 * API endpoint: POST /api/transactions/export
 * Tạo phiếu xuất kho thủ công
 *
 * Body:
 *  - note?: string | null
 *  - items: {
 *      productPackageId: string;
 *      quantity: number;
 *      unitPrice: number;
 *    }[]
 */
transactionRouter.post(
  '/export',
  requirePermission(PERMISSION.INVENTORY_TRANSACTION_CREATE),
  validateCreateExportTransaction,
  asyncWrapper(transactionController.createExportTransaction),
);

export { transactionRouter };
