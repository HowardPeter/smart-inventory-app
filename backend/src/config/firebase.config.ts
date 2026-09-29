import 'dotenv/config';
import { readFileSync } from 'fs';
import { join } from 'path';

import {
  initializeApp,
  cert,
  getApps,
  type ServiceAccount,
} from 'firebase-admin/app';
import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../common/errors/custom-error.js';

const getFirebaseServiceAccount = (): ServiceAccount => {
  if (process.env.NODE_ENV !== 'production') {
    const serviceAccountPath = join(process.cwd(), 'serviceAccountKey.json');

    return JSON.parse(readFileSync(serviceAccountPath, 'utf8'));
  }

  const serviceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;

  if (!serviceAccountKey) {
    throw new CustomError({
      status: StatusCodes.INTERNAL_SERVER_ERROR,
      message: 'FIREBASE_SERVICE_ACCOUNT_KEY is missing',
      isOperational: false,
    });
  }

  return JSON.parse(serviceAccountKey);
};

export const initFirebaseAdmin = () => {
  if (!getApps().length) {
    try {
      initializeApp({
        credential: cert(getFirebaseServiceAccount()),
      });

      console.info('[Firebase] Admin SDK initialized successfully');
    } catch (error) {
      console.error(
        '[Firebase] Lỗi khởi tạo Admin SDK. Vui lòng kiểm tra file serviceAccountKey.json',
        error,
      );
    }
  }
};
