import { appEvents, eventBus } from '../../common/events/event-bus.js';
import { prisma } from '../../db/prismaClient.js';

import type {
  BatchReorderSuggestionPayload,
  ReorderSuggestionItem,
} from '../../common/events/event-payloads.js';

export class SmartDecisionService {
  public async generateReorderSuggestions() {
    console.info('[Smart Decision] Starting reorder analysis...');

    const thirtyDaysAgo = new Date();

    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const inventories = await prisma.inventory.findMany({
      where: { activeStatus: 'active' },
      include: {
        productPackage: {
          include: {
            product: {
              include: { category: true },
            },
          },
        },
      },
    });

    const storeSuggestions: Record<string, ReorderSuggestionItem[]> = {};

    for (const inv of inventories) {
      const storeId = inv.productPackage.product.storeId;
      const pkgId = inv.productPackageId;

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
      const ads = totalSold / 30;

      // Bỏ qua nếu không có lịch sử bán hàng (Sản phẩm mới hoặc ế)
      if (ads === 0) {
        continue;
      }

      const categoryName =
        inv.productPackage.product.category.name.toLowerCase();

      let leadTime = 3;
      let safetyStockDays = 2;

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
          if (!storeSuggestions[storeId]) {
            storeSuggestions[storeId] = [];
          }

          storeSuggestions[storeId].push({
            productId: inv.productPackage.productId,
            productName: inv.productPackage.displayName ?? 'Product',
            currentStock: inv.quantity,
            suggestedQuantity: suggestedQty,
            suggestedThreshold: reorderPoint,
            reason: `Based on sales velocity of ${ads.toFixed(1)} units/day.`,
          });
        }
      }
    }

    for (const [storeId, suggestions] of Object.entries(storeSuggestions)) {
      if (suggestions.length > 0) {
        const payload: BatchReorderSuggestionPayload = { storeId, suggestions };

        eventBus.emit(appEvents.BATCH_REORDER_SUGGESTION, payload);
      }
    }

    console.info('[Smart Decision] Analysis completed.');
  }
}

export const smartDecisionService = new SmartDecisionService();
