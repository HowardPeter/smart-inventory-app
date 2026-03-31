import { Router } from 'express';

import { unitController } from './unit.module.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../auth/index.js';

const unitRouter = Router();

unitRouter.get('/', authenticate, asyncWrapper(unitController.getUnits));

export { unitRouter };
