import { appEvents, eventBus } from '../../common/events/event-bus.js';
import { prisma } from '../../db/prismaClient.js';

import type { ReorderSuggestionItemDto } from './dto/smart-decision.dto.js';
import type { BatchReorderSuggestionPayload } from '../../common/events/event-payloads.js';

export class SmartDecisionService {
  // =====================================================================
  // 1. HÀM CORE: TÍNH TOÁN GỢI Ý CHO 1 CỬA HÀNG (DÙNG CHO CẢ API & CRON)
  // =====================================================================
  public async getStoreReorderSuggestions(
    storeId: string,
  ): Promise<ReorderSuggestionItemDto[]> {
    const thirtyDaysAgo = new Date();

    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    // Lấy tồn kho của riêng store đang request
    const inventories = await prisma.inventory.findMany({
      where: {
        activeStatus: 'active',
        productPackage: {
          product: { storeId: storeId },
        },
      },
      include: {
        productPackage: {
          include: {
            product: { include: { category: true } },
          },
        },
      },
    });

    const suggestions: ReorderSuggestionItemDto[] = [];

    for (const inv of inventories) {
      const pkgId = inv.productPackageId;

      // Tính tổng bán ra trong 30 ngày qua
      const salesData = await prisma.transactionDetail.aggregate({
        _sum: { quantity: true },
        where: {
          productPackageId: pkgId,
          transaction: {
            type: 'export',
            status: 'completed',
            createdAt: { gte: thirtyDaysAgo },
          },
        },
      });

      const totalSold = salesData._sum.quantity ?? 0;
      const ads = totalSold / 30; // Average Daily Sales

      if (ads === 0) {
        continue;
      }

      const categoryName =
        inv.productPackage.product.category.name.toLowerCase();

      let leadTime = 3;
      let safetyStockDays = 2;

      // Phân loại Category Rule
      if (
        ['food', 'beverage', 'groceries', 'medical', 'health'].some((k) =>
          categoryName.includes(k),
        )
      ) {
        leadTime = 2;
        safetyStockDays = 1;
      } else if (
        ['apparel', 'clothing', 'accessories', 'office', 'stationery'].some(
          (k) => categoryName.includes(k),
        )
      ) {
        leadTime = 4;
        safetyStockDays = 2;
      } else if (
        ['electronic', 'appliance', 'lighting', 'security', 'tech'].some((k) =>
          categoryName.includes(k),
        )
      ) {
        leadTime = 7;
        safetyStockDays = 3;
      } else if (
        ['furniture', 'garden', 'outdoor', 'industrial', 'heavy'].some((k) =>
          categoryName.includes(k),
        )
      ) {
        leadTime = 10;
        safetyStockDays = 4;
      } else if (
        ['digital', 'software', 'license', 'virtual'].some((k) =>
          categoryName.includes(k),
        )
      ) {
        leadTime = 0;
        safetyStockDays = 0;
      }

      const safetyStock = Math.ceil(ads * safetyStockDays);
      const reorderPoint = Math.ceil(ads * leadTime + safetyStock);

      if (inv.quantity <= reorderPoint) {
        const daysToCover = 14;
        const targetStock = reorderPoint + Math.ceil(ads * daysToCover);
        const suggestedQty = targetStock - inv.quantity;

        if (suggestedQty > 0) {
          suggestions.push({
            productId: inv.productPackage.productId,
            productName: inv.productPackage.displayName ?? 'Sản phẩm',
            currentStock: inv.quantity,
            suggestedQuantity: suggestedQty,
            suggestedThreshold: reorderPoint,
            reason: `Dựa trên tốc độ bán trung bình ${ads.toFixed(1)} SP/ngày.`,
          });
        }
      }
    }

    return suggestions;
  }

  // =====================================================================
  // 2. HÀM CRON JOB: QUÉT TẤT CẢ CỬA HÀNG VÀ BẮN EVENT (DÙNG CHO BACKGROUND)
  // =====================================================================
  public async generateReorderSuggestions() {
    console.info('[Smart Decision] Starting reorder analysis...');

    // Lấy danh sách các cửa hàng đang hoạt động
    const stores = await prisma.store.findMany({
      where: { activeStatus: 'active' },
      select: { storeId: true },
    });

    for (const store of stores) {
      // Tái sử dụng hàm logic lõi ở trên
      const suggestions = await this.getStoreReorderSuggestions(store.storeId);

      if (suggestions.length > 0) {
        const payload: BatchReorderSuggestionPayload = {
          storeId: store.storeId,
          suggestions,
        };

        eventBus.emit(appEvents.BATCH_REORDER_SUGGESTION, payload);
      }
    }

    console.info('[Smart Decision] Analysis completed.');
  }
}

// Xóa instance global cũ đi nếu bạn định dùng Dependency Injection ở module.ts
// export const smartDecisionService = new SmartDecisionService();
