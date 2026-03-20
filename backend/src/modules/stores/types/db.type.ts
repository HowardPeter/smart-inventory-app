import type { PrismaClient, Prisma } from '../../../generated/prisma/client.js';

export type DbClient = PrismaClient | Prisma.TransactionClient;
