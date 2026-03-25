/* Định nghĩa các kiểu dữ liệu gốc (Domain Types) cho module Audit Log.
Mô phỏng chính xác cấu trúc dữ liệu từ cơ sở dữ liệu (Prisma),
làm nền tảng gốc để dẫn xuất ra các DTO
(sử dụng Pick, Omit, Partial,...) nhằm tránh lặp code. */

import type { AuditActionType, Prisma } from '../../generated/prisma/client.js';

export type AuditLog = {
  eventId: string;
  actionType: AuditActionType | null;
  entityType: string | null;
  oldValue: Prisma.JsonValue | null;
  newValue: Prisma.JsonValue | null;
  performedAt: Date;
  userId: string;
  storeId: string;
};
