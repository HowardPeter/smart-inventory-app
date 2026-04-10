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
        oldQuantity?: number; // <--- Đón nhận thêm oldQuantity
        newQuantity?: number;
      }) => {
        this.checkLowStockRule(
          payload.inventoryId,
          payload.storeId,
          payload.newQuantity,
          payload.oldQuantity, // <--- Truyền xuống hàm check
        ).catch((err) => console.error('Lỗi khi check rules:', err));
      },
    );
  }

  // 2. LOGIC KIỂM TRA CHỐNG SPAM & GỬI ĐÚNG NGƯỜI
  public async checkLowStockRule(
    inventoryId: string,
    providedStoreId?: string,
    newQuantity?: number,
    oldQuantity?: number, // <--- Nhận tham số mới
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
    const targetMembers = await prisma.storeMember.findMany({
      where: {
        storeId: storeId,
        role: { in: ['owner', 'manager'] }, // Chỉ lấy Owner và Manager
        activeStatus: 'active',
      },
      select: { userId: true },
    });

    if (targetMembers.length === 0) {
      return;
    }

    const productName = inventory.productPackage?.product?.name ?? 'Sản phẩm';

    // Dùng Promise.all để gửi đồng loạt không bị nghẽn
    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Tồn kho ở mức báo động',
          `${productName} chỉ còn ${currentQty} đơn vị. Hãy nhập thêm!`,
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

    for (const inv of lowInventories) {
      const storeId = inv.productPackage?.product?.storeId;

      if (storeId) {
        await this.checkLowStockRule(inv.inventoryId, storeId);
      }
    }
  }
}

export const smartAlertService = new SmartAlertService(
  new NotificationService(new NotificationRepository()),
);
