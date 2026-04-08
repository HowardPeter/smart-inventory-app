import type { DbClient } from '../../../common/types/index.js';
import type {
  TransactionDetailResponseDto,
  CreateTransactionDetailData,
} from '../transaction.dto.js';

export class TransactionDetailRepository {
  constructor(private readonly db: DbClient) {}

  async findMany(
    data: CreateTransactionDetailData,
  ): Promise<TransactionDetailResponseDto[]> {
    const transactionDetails = await this.db.transactionDetail.findMany({
      where: {
        transactionId: data.transactionId,
        productPackageId: {
          in: data.items.map((item) => item.productPackageId),
        },
      },
      select: {
        transactionId: true,
        productPackageId: true,
        quantity: true,
        unitPrice: true,
      },
    });

    return transactionDetails.map((transactionDetail) => ({
      transactionId: transactionDetail.transactionId,
      productPackageId: transactionDetail.productPackageId,
      quantity: transactionDetail.quantity,
      unitPrice: transactionDetail.unitPrice.toNumber(),
    }));
  }

  async createMany(data: CreateTransactionDetailData): Promise<void> {
    await this.db.transactionDetail.createMany({
      data: data.items.map((item) => ({
        transactionId: data.transactionId,
        productPackageId: item.productPackageId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      })),
    });
  }
}
