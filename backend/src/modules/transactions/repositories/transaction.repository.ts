import type { DbClient } from '../../../common/types/index.js';
import type {
  TransactionResponseDto,
  CreateTransactionData,
} from '../transaction.dto.js';

export class TransactionRepository {
  constructor(private readonly db: DbClient) {}

  async createOne(
    data: CreateTransactionData,
  ): Promise<TransactionResponseDto> {
    const transaction = await this.db.transaction.create({
      data: {
        type: data.type,
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
