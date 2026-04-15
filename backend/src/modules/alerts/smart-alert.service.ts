import { appEvents, eventBus } from '../../common/events/event-bus.js';
import { prisma } from '../../db/prismaClient.js';
import { NotificationRepository } from '../notification/repositories/notification.repository.js';
import { NotificationService } from '../notification/services/notification.service.js';

export class SmartAlertService {
  constructor(private readonly notificationService: NotificationService) {
    this.initEventListeners();
  }

  // 1. LẮNG NGHE SỰ KIỆN REAL-TIME
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

  // 2. LOGIC KIỂM TRA CHỐNG SPAM & GỬI ĐÚNG NGƯỜI
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
      inventory.productPackage?.displayName ??
      'The product package name has not been updated.';

    // Dùng Promise.all để gửi đồng loạt không bị nghẽn
    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Tồn kho ở mức báo động',
          `${productName} chỉ còn ${currentQty} sản phẩm.\nHãy nhập thêm!`,
          'LOW_STOCK',
          inventory.productPackageId,
        ),
      ),
    );
  }

  // 3. HÀM DÀNH CHO CRON JOB QUÉT ĐỊNH KỲ (Giữ nguyên như của bạn)
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

    // Sử dụng interface đã định nghĩa thay vì Record<string, any[]>
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

    // Phân loại nội dung thông báo dựa trên số lượng
    if (totalLowStock === 1) {
      bodyText = `Sản phẩm ${sampleNamesArray[0]} đang ở mức báo động.\nHãy kiểm tra và nhập thêm!`;
    } else if (totalLowStock === 2) {
      bodyText = `Các sản phẩm ${sampleNamesArray.join(', ')} đang ở mức báo động.\nHãy kiểm tra và nhập thêm!`;
    } else {
      // Từ 3 sản phẩm trở lên mới dùng chữ "VD" và dấu "..."
      const sampleNames = sampleNamesArray.slice(0, 2).join(', ');

      bodyText = `Có ${totalLowStock} sản phẩm đang ở mức báo động (VD: ${sampleNames},...).\nHãy kiểm tra và nhập thêm!`;
    }

    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Báo cáo Tồn kho thấp',
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
    // 1. Query 1 lần lấy thông tin chi tiết của tất cả sản phẩm trong giao dịch
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

    // 3. Nếu không có sản phẩm nào chạm ngưỡng, kết thúc!
    if (lowStockItems.length === 0) {
      return;
    }

    // 4. Nếu có, tái sử dụng hàm gộp để bắn 1 thông báo duy nhất
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
