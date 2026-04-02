import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../common/errors/index.js';
import { prisma } from '../../db/prismaClient.js';
import { Prisma } from '../../generated/prisma/client.js';
import { InventoryService } from '../inventories/index.js';
import { ProductPackageService } from '../product-packages/index.js';
import { ProductService } from '../products/index.js';
import { TransactionDetailRepository } from './repositories/transaction-detail.repository.js';
import { TransactionRepository } from './repositories/transaction.repository.js';

import type {
  CreateImportTransactionDto,
  CreateImportTransactionResponseDto,
  PriceUpdateSuggestionDto,
} from './transaction.dto.js';

export class TransactionService {
  constructor(
    private readonly productService: ProductService,
    private readonly productPackageService: ProductPackageService,
    private readonly inventoryService: InventoryService,
  ) {}

  private ensureNoDuplicateProductPackageIds(
    data: CreateImportTransactionDto,
  ): void {
    // INFO: Sử dụng Set giúp kiểm tra và loại bỏ phần tử trùng
    const productPackageIds = new Set<string>();

    // Kiểm tra productPackageId trong data đã có trong productPackageIds chưa,
    // nếu true thì báo lỗi trùng package
    for (const item of data.items) {
      if (productPackageIds.has(item.productPackageId)) {
        throw new CustomError({
          message: 'Duplicate productPackageId in transaction items',
          code: 'DUPLICATE_PRODUCT_PACKAGE',
          status: StatusCodes.BAD_REQUEST,
        });
      }

      // ngược lại thì thêm vào productPackageIds
      productPackageIds.add(item.productPackageId);
    }
  }

  private calculateTotalPrice(
    data: CreateImportTransactionDto,
  ): Prisma.Decimal {
    return data.items.reduce(
      (totalPrice, item) =>
        totalPrice.plus(new Prisma.Decimal(item.unitPrice).mul(item.quantity)),
      new Prisma.Decimal(0),
    );
  }

  private buildPriceUpdateSuggestions(
    data: CreateImportTransactionDto,
    productPackageMap: Map<
      string,
      {
        productPackageId: string;
        productId: string;
        displayName: string | null;
        importPrice: number | null;
      }
    >,
  ): PriceUpdateSuggestionDto[] {
    const priceUpdateSuggestions: PriceUpdateSuggestionDto[] = [];

    for (const item of data.items) {
      // gán phần tử trong productPackageMap cho productPackage
      const productPackage = productPackageMap.get(item.productPackageId);

      // skip loop nếu không tìm thấy
      if (!productPackage) {
        continue;
      }

      // skip loop nếu có importPrice và importPrice = unitPrice
      // convert về Decimal để tăng độ chính xác (khi cần)
      if (
        productPackage.importPrice !== null &&
        new Prisma.Decimal(new Prisma.Decimal(productPackage.importPrice)).cmp(
          new Prisma.Decimal(item.unitPrice),
        ) === 0
      ) {
        continue;
      }

      // thêm phần tử Package vào nếu phát hiện unitPrice !== importPrice
      priceUpdateSuggestions.push({
        productPackageId: item.productPackageId,
        currentImportPrice: productPackage.importPrice,
        latestImportUnitPrice: item.unitPrice,
      });
    }

    return priceUpdateSuggestions;
  }

  async createImportTransaction(
    storeId: string,
    userId: string,
    data: CreateImportTransactionDto,
  ): Promise<CreateImportTransactionResponseDto> {
    if (data.items.length === 0) {
      throw new CustomError({
        message: 'Items cannot be empty',
        code: 'PACKAGE_ITEM_IS_EMPTY',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    this.ensureNoDuplicateProductPackageIds(data);

    // Lấy danh sách productId unique
    // Set -> loại duplicate, Array.from -> convert lại thành array
    const productIds = Array.from(
      new Set(data.items.map((item) => item.productId)),
    );

    // Lấy danh sách productPackageId unique
    const productPackageIds = Array.from(
      new Set(data.items.map((item) => item.productPackageId)),
    );

    // Gọi song song 3 API để tối ưu performance (Promise.all)
    // destructuring để lấy kết quả theo thứ tự
    const [products, productIdsHavingPackages, productPackages] =
      await Promise.all([
        // Lấy product active theo store
        this.productService.getActiveProductsByIds(storeId, productIds),

        // Lấy danh sách productId đã có ít nhất 1 package
        this.productPackageService.getProductIdsHavingPackages(
          storeId,
          productIds,
        ),

        // Lấy danh sách ProductPackage
        this.productPackageService.getProductPackagesByIds(
          storeId,
          productPackageIds,
        ),
      ]);

    // INFO: Sử dụng Map để lookup O(1) thay vì find O(n)
    const productMap = new Map(
      products.map((product) => [product.productId, product]),
    );

    // Map để lookup ProductPackage theo id
    const productPackageMap = new Map(
      productPackages.map((productPackage) => [
        productPackage.productPackageId,
        productPackage,
      ]),
    );

    // Tạo Set để check nhanh product có package chưa
    const productIdsHavingPackagesSet = new Set(productIdsHavingPackages);

    for (const item of data.items) {
      const product = productMap.get(item.productId);

      if (!product) {
        throw new CustomError({
          message: 'Product not found',
          status: StatusCodes.NOT_FOUND,
        });
      }

      // NOTE: Business rule:
      // NOTE: Product chưa có package -> frontend cần mở overlay tạo package
      if (!productIdsHavingPackagesSet.has(item.productId)) {
        throw new CustomError({
          message:
            'Product has no package. Please create a package and inventory first.',
          status: StatusCodes.CONFLICT,
          code: 'PRODUCT_HAS_NO_PACKAGE',
          details: {
            productId: product.productId,
            productName: product.name,
          },
        });
      }

      const productPackage = productPackageMap.get(item.productPackageId);

      // Package không tồn tại
      // Tránh trường hợp frontend load lỗi, data chưa sync, race condition
      if (!productPackage) {
        throw new CustomError({
          message: 'Product package not found',
          status: StatusCodes.NOT_FOUND,
        });
      }

      // Package không thuộc product đã chọn
      // Tránh trường hợp frontend load lỗi, data chưa sync, race condition
      if (productPackage.productId !== item.productId) {
        throw new CustomError({
          message: 'Product package does not belong to the selected product',
          status: StatusCodes.BAD_REQUEST,
        });
      }
    }

    const totalPrice = this.calculateTotalPrice(data).toNumber();

    // Xây dựng danh sách package có giá thay đổi
    // frontend sẽ dùng để hỏi user có update importPrice không
    const priceUpdateSuggestions = this.buildPriceUpdateSuggestions(
      data,
      productPackageMap,
    );

    return await prisma.$transaction(async (tx) => {
      const transactionRepositoryTx = new TransactionRepository(tx);
      const transactionDetailRepositoryTx = new TransactionDetailRepository(tx);

      const transaction = await transactionRepositoryTx.createImportTransaction(
        {
          note: data.note ?? null,
          totalPrice,
          userId,
          storeId,
        },
      );

      await transactionDetailRepositoryTx.createMany({
        transactionId: transaction.transactionId,
        items: data.items.map((item) => ({
          productPackageId: item.productPackageId,
          quantity: item.quantity,
          unitPrice: new Prisma.Decimal(item.unitPrice),
        })),
      });

      // Cập nhật tồn kho
      await this.inventoryService.increaseInventoriesForImport(
        storeId,
        userId,
        data.items.map((item) => ({
          productPackageId: item.productPackageId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          transactionId: transaction.transactionId,
        })),
        tx,
      );

      return {
        ...transaction,
        items: data.items,
        priceUpdateSuggestions,
      };
    });
  }
}
