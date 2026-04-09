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
      (payload: { inventoryId: string; storeId: string }) => {
        this.checkLowStockRule(payload.inventoryId, payload.storeId).catch(
          (err) => console.error('Lỗi khi check rules:', err),
        );
      },
    );
  }

  // 2. LOGIC KIỂM TRA DÙNG CHUNG (TÁI SỬ DỤNG)
  public async checkLowStockRule(
    inventoryId: string,
    providedStoreId?: string,
  ) {
    const inventory = await prisma.inventory.findUnique({
      where: { inventoryId: inventoryId },
      include: {
        // Dò theo đúng chuỗi: Inventory -> ProductPackage -> Product -> Store
        productPackage: {
          include: {
            product: {
              include: {
                store: true, // Tới đây mới lấy được thông tin Store và Owner
              },
            },
          },
        },
      },
    });

    if (!inventory) {
      return;
    }

    const threshold = inventory.reorderThreshold ?? 0;

    // RULE: Nếu số lượng hiện tại <= ngưỡng an toàn
    if (inventory.quantity <= threshold) {
      const product = inventory.productPackage?.product;
      const productName = product?.name ?? 'Sản phẩm';

      // Lấy storeId (ưu tiên cái truyền vào, nếu không có thì lấy từ DB)
      const storeId = providedStoreId || product?.storeId;
      // Lấy userId của chủ cửa hàng từ bảng Store
      const ownerId = product?.store?.userId;

      if (!storeId || !ownerId) {
        return;
      } // Bảo vệ an toàn tránh lỗi null

      await this.notificationService.createAndSendNotification(
        ownerId, // Gửi cho người tạo cửa hàng
        storeId,
        '⚠️ Tồn kho ở mức báo động',
        `${productName} chỉ còn ${inventory.quantity} đơn vị. Hãy nhập thêm!`,
        'LOW_STOCK',
        inventory.productPackageId,
        // Trỏ về gói sản phẩm để app mở đúng màn hình
      );
    }
  }

  // 3. HÀM DÀNH CHO CRON JOB QUÉT ĐỊNH KỲ
  public async scanAllStoresForLowStock() {
    console.info('[Cron] Đang quét toàn hệ thống tìm hàng tồn kho thấp...');

    const lowInventories = await prisma.inventory.findMany({
      where: {
        reorderThreshold: { not: null },
        quantity: { lte: prisma.inventory.fields.reorderThreshold },
        activeStatus: 'active',
      },
      include: {
        // Include để lấy storeId truyền vào hàm check
        productPackage: {
          include: {
            product: true,
          },
        },
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
// KHỞI TẠO INSTANCE ĐỂ EXPORT DÙNG CHUNG CHO CRON JOB VÀ CÁC MODULE KHÁC
// (Lưu ý: Bạn cần import notificationRepository vào đây hoặc
// quản lý qua Dependency Injection của project)
export const smartAlertService = new SmartAlertService(
  new NotificationService(new NotificationRepository()),
);
