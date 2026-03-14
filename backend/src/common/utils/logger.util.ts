import 'dotenv/config';
import pino, { type LoggerOptions } from 'pino';

const isProd = process.env.NODE_ENV === 'production';

const loggerOptions: LoggerOptions = {
  level: isProd ? 'info' : 'debug',
  base: {
    service: 'backend',
  },
};

// Nếu là môi trường dev thì in ra kiểu pretty
if (!isProd) {
  loggerOptions.transport = {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
    },
  };
}

export const logger = pino(loggerOptions);
