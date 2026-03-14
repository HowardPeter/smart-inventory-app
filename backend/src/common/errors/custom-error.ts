export class CustomError extends Error {
  public readonly status: number;
  public readonly code?: string;
  public readonly isOperational: boolean;

  constructor(options: {
    message: string;
    status: number;
    code?: string;
    details?: Record<string, unknown>;
    isOperational?: boolean; // true nếu lỗi thuộc business logic
  }) {
    super(options.message);

    this.name = 'CustomError';
    this.status = options.status;
    this.isOperational = options.isOperational ?? true;

    if (options?.code !== undefined) {
      this.code = options.code;
    }

    Error.captureStackTrace(this, this.constructor);
  }
}
