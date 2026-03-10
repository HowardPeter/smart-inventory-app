import type { Request, Response, NextFunction } from 'express';

export const errorHandler = (
  err: unknown,
  req: Request,
  res: Response,
  // Thêm '_' để ts và eslint bỏ qua unused parameter vì next buộc phải khai báo
  _next: NextFunction,
) => {
  console.error(err);

  res.status(500).json({
    success: false,
    message: err instanceof Error ? err.message : 'Internal Server Error',
  });
};
