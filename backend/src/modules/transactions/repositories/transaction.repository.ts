import type { DbClient } from '../../../common/types/index.js';
import type {
  ImportTransactionResponseDto,
  CreateImportTransactionData,
} from '../transaction.dto.js';

export class TransactionRepository {
  constructor(private readonly db: DbClient) {}

  async createImportTransaction(
    data: CreateImportTransactionData,
  ): Promise<ImportTransactionResponseDto> {
    const transaction = await this.db.transaction.create({
      data: {
        type: 'import',
        status: 'completed',
        note: data.note ?? null,
        totalPrice: data.totalPrice,
        userId: data.userId,
        storeId: data.storeId,
      },
      select: {
        transactionId: true,
        type: true,
        note: true,
        status: true,
        createdAt: true,
        totalPrice: true,
      },
    });

    return {
      ...transaction,
      totalPrice: transaction.totalPrice.toNumber(),
    };
  }
}
