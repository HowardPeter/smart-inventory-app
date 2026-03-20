import express from 'express';

import { errorHandler } from './common/middlewares/index.js';
import { sendResponse } from './common/utils/index.js';
import { productRouter } from './modules/products/index.js';
import { storeRouter } from './modules/stores/index.js';
import { userProfileRouter } from './modules/user-profile/index.js';
import { categoryRouter } from '../src/modules/categories/index.js';

import type { ApiResponse } from './common/types/index.js';
import type { Request, Response } from 'express';

const app = express();
const port = 3000;

app.use(express.json());

app.get('/api/health', (_req: Request, res: Response<ApiResponse<null>>) => {
  return sendResponse.success(res, null, { message: 'ok' });
});

app.use('/api/stores', storeRouter);
app.use('/api/products', productRouter);
app.use('/api/categories', categoryRouter);
app.use('/api/auth', userProfileRouter);

app.use(errorHandler);

app.listen(port, () => {
  console.info(`Server is running on http://localhost:${port}`);
});
