import express from 'express';

import { errorHandler } from './middlewares/index.js';

import type { Request, Response } from 'express';

const app = express();
const port = 3000;

app.use(express.json());

app.get('/api/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok' });
});

app.use(errorHandler);

app.listen(port, () => {
  console.info(`Server is running on http://localhost:${port}`);
});
