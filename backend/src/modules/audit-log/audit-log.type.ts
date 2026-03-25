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
