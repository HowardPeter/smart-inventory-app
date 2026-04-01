import { Router } from 'express';

import { asyncWrapper } from '../../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../../auth/index.js';
import { unitController } from '../modules/unit.module.js';

const unitRouter = Router();

/**
 * API endpoint: GET /api/units
 * Lấy danh sách các đơn vị trong hệ thống
 */
unitRouter.get('/', authenticate, asyncWrapper(unitController.getUnits));

export { unitRouter };
