import { ZodObject } from 'zod';

import { validateSchema } from '../utils/validate-schema.util.js';

import type { Request, Response, NextFunction } from 'express';
// Thay đổi đường dẫn import này trỏ tới đúng file util của bạn
// import { validateSchema } from '../utils/validate-schema.util.js';

export const validator = (schema: ZodObject) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      // Đóng gói request thành object khớp với cấu trúc Zod Schema của dự án
      validateSchema(schema, {
        body: req.body,
        query: req.query,
        params: req.params,
      });

      next(); // Nếu hợp lệ, cho luồng đi tiếp vào Controller
    } catch (error) {
      next(error); // Chuyển CustomError về cho Error Handler tổng xử lý
    }
  };
};
