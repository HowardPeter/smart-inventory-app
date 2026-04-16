import { getRandomMessage } from './utils/message.util.js';
import { appEvents, eventBus } from '../../common/events/event-bus.js';
import { prisma } from '../../db/prismaClient.js';
import { NotificationRepository } from '../notification/repositories/notification.repository.js';
import { NotificationService } from '../notification/services/notification.service.js';

export class SmartAlertService {
  constructor(private readonly notificationService: NotificationService) {
    this.initEventListeners();
  }

  private initEventListeners() {
    eventBus.on(
      appEvents.INVENTORY_CHANGED,
      (payload: {
        inventoryId: string;
        storeId: string;
        oldQuantity?: number;
        newQuantity?: number;
      }) => {
        this.checkLowStockRule(
          payload.inventoryId,
          payload.storeId,
          payload.newQuantity,
          payload.oldQuantity,
        ).catch((err) => console.error('Lỗi khi check rules:', err));
      },
    );

    eventBus.on(
      appEvents.BATCH_INVENTORY_CHANGED,
      (payload: {
        storeId: string;
        items: Array<{
          inventoryId: string;
          oldQuantity: number;
          newQuantity: number;
        }>;
      }) => {
        this.checkBatchLowStockRule(payload).catch((err) =>
          console.error('Lỗi khi check batch rules:', err),
        );
      },
    );
  }

  public async checkLowStockRule(
    inventoryId: string,
    providedStoreId?: string,
    newQuantity?: number,
    oldQuantity?: number,
  ) {
    const inventory = await prisma.inventory.findUnique({
      where: { inventoryId: inventoryId },
      include: {
        productPackage: {
          include: {
            product: true,
          },
        },
      },
    });

    if (!inventory) {
      return;
    }

    const threshold = inventory.reorderThreshold ?? 0;
    const currentQty = newQuantity ?? inventory.quantity;

    if (oldQuantity !== undefined) {
      // Dành cho Real-time: Chỉ báo động khi VỪA RỚT QUA NGƯỠNG
      const isSafe = oldQuantity > threshold;
      const isNowLow = currentQty <= threshold;

      // Nếu trước đó đã thấp sẵn rồi (isSafe = false)
      // thì KHÔNG gửi nữa (Chống Spam)
      if (!(isSafe && isNowLow)) {
        return;
      }
    } else {
      // Dành cho Cron Job (quét tự động không có oldQuantity):
      // Lấy tất cả kho <= ngưỡng
      if (currentQty > threshold) {
        return;
      }
    }

    // Lấy storeId
    const storeId =
      providedStoreId || inventory.productPackage?.product?.storeId;

    if (!storeId) {
      return;
    }

    // Lấy danh sách Chủ và Quản lý của cửa hàng này
    const targetMembers = await this.getTargetMembers(storeId);

    if (targetMembers.length === 0) {
      return;
    }

    // Lấy tên của từng product package để gửi thông báo chính xác!
    const productName =
      inventory.productPackage?.displayName ?? 'An unnamed product';

    const bodyTemplates = [
      `${productName} is running low! Only ${currentQty} left in stock.`,
      `Action required: ${productName} has dropped to ${currentQty} units.`,
      `Restock reminder: You have ${currentQty} units of ${productName} remaining.`,
      `Heads up! ${productName} has reached its reorder threshold (${currentQty} left).`,
    ];

    const bodyText = getRandomMessage(bodyTemplates);

    // Dùng Promise.all để gửi đồng loạt không bị nghẽn
    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Low Stock Alert',
          bodyText,
          'LOW_STOCK',
          inventory.productPackage?.productId,
        ),
      ),
    );
  }

  public async scanAllStoresForLowStock() {
    console.info('[Cron] Đang quét toàn hệ thống tìm hàng tồn kho thấp...');

    const lowInventories = await prisma.inventory.findMany({
      where: {
        reorderThreshold: { not: null },
        quantity: { lte: prisma.inventory.fields.reorderThreshold },
        activeStatus: 'active',
      },
      include: {
        productPackage: { include: { product: true } },
      },
    });

    if (lowInventories.length === 0) {
      console.info(
        '[Cron] Không phát hiện sản phẩm nào có tồn kho thấp. Đã dừng quy trình quét.',
      );

      return;
    }

    const storeDeficits: Record<string, LowStockInventoryItem[]> = {};

    for (const inv of lowInventories) {
      const storeId = inv.productPackage?.product?.storeId;

      if (storeId) {
        if (!storeDeficits[storeId]) {
          storeDeficits[storeId] = [];
        }
        storeDeficits[storeId].push(inv as LowStockInventoryItem);
      }
    }

    // Duyệt qua từng storeId và gửi 1 thông báo tổng hợp
    for (const [storeId, inventories] of Object.entries(storeDeficits)) {
      await this.processBatchNotification(storeId, inventories);
    }
  }

  // Hàm mới xử lý gửi thông báo gộp (Không đụng chạm tới checkLowStockRule)
  private async processBatchNotification(
    storeId: string,
    inventories: LowStockInventoryItem[],
  ) {
    const targetMembers = await this.getTargetMembers(storeId);

    if (targetMembers.length === 0) {
      return;
    }

    const totalLowStock = inventories.length;

    // Lấy mảng tên các sản phẩm hợp lệ
    const sampleNamesArray = inventories
      .map((inv) => inv.productPackage?.displayName)
      .filter(Boolean);

    let bodyText = '';
    let bodyTemplates: string[] = [];

    // Phân loại nội dung thông báo dựa trên số lượng & tạo mảng templates
    if (totalLowStock === 1) {
      const name = sampleNamesArray[0] || 'A product';

      bodyTemplates = [
        `The item ${name} is critically low. Please restock soon!`,
        `Inventory alert: ${name} is almost out of stock.`,
        `Restock needed: ${name} has dropped below the safe limit.`,
      ];
    } else if (totalLowStock === 2) {
      const names = sampleNamesArray.join(' and ');

      bodyTemplates = [
        `${names} are running low on stock. Please review.`,
        `Action required: Stock is low for both ${names}.`,
        `Restock reminder: It's time to order more ${names}.`,
      ];
    } else {
      const names = sampleNamesArray.slice(0, 2).join(', ');

      bodyTemplates = [
        `${totalLowStock} items need restocking (e.g., ${names}, ...).`,
        `Multiple items are low on stock! (${totalLowStock} total, including ${names}, ...).`,
        `Inventory warning: ${totalLowStock} products have hit their reorder point (like ${names}, ...).`,
      ];
    }

    bodyText = getRandomMessage(bodyTemplates);

    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Inventory Warning',
          bodyText,
          appEvents.BATCH_LOW_STOCK,
          undefined,
        ),
      ),
    );
  }

  public async checkBatchLowStockRule(payload: {
    storeId: string;
    items: Array<{
      inventoryId: string;
      oldQuantity: number;
      newQuantity: number;
    }>;
  }) {
    const inventoryIds = payload.items.map((item) => item.inventoryId);

    const inventories = await prisma.inventory.findMany({
      where: { inventoryId: { in: inventoryIds } },
      include: {
        productPackage: { include: { product: true } },
      },
    });

    const lowStockItems: LowStockInventoryItem[] = [];

    for (const inv of inventories) {
      const threshold = inv.reorderThreshold ?? 0;
      const payloadItem = payload.items.find(
        (i) => i.inventoryId === inv.inventoryId,
      );

      if (!payloadItem) {
        continue;
      }

      const isSafe = payloadItem.oldQuantity > threshold;
      const isNowLow = payloadItem.newQuantity <= threshold;

      if (isSafe && isNowLow) {
        // Gán quantity mới vào object để gửi đi nếu cần
        const itemToAlert = { ...inv, quantity: payloadItem.newQuantity };

        lowStockItems.push(itemToAlert as LowStockInventoryItem);
      }
    }

    if (lowStockItems.length === 0) {
      return;
    }

    await this.processBatchNotification(payload.storeId, lowStockItems);
  }

  private async getTargetMembers(storeId: string) {
    return await prisma.storeMember.findMany({
      where: {
        storeId: storeId,
        role: { in: ['owner', 'manager'] },
        activeStatus: 'active',
      },
      select: { userId: true },
    });
  }
}

export const smartAlertService = new SmartAlertService(
  new NotificationService(new NotificationRepository()),
);

interface LowStockInventoryItem {
  inventoryId: string;
  quantity: number;
  productPackage?: {
    displayName: string | null;
    product?: {
      storeId: string | null;
    } | null;
  } | null;
}
