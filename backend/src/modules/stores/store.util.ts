// src/common/utils/string.util.ts
import { randomBytes } from 'crypto';

/**
 * Tạo một mã ngẫu nhiên có định dạng xxxx-xxxx-xxxx-xxxx.
 * Mã này được sinh từ các ký tự (chữ thường và số) và chia thành 4 nhóm.
 * * @param length Số lượng byte ngẫu nhiên cần tạo (mặc định là 16)
 * @returns Chuỗi ngẫu nhiên định dạng xxxx-xxxx-xxxx-xxxx
 */
export const generateFormattedInviteCode = (length: number = 16): string => {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let rawCode = '';

  const randomArray = randomBytes(length);

  for (let i = 0; i < length; i++) {
    rawCode += chars[randomArray[i]! % chars.length];
  }

  // Chia thành các đoạn 4 ký tự và nối bằng '-'
  return rawCode.match(/.{1,4}/g)?.join('-') || rawCode;
};
