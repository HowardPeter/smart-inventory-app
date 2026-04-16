import EventEmitter from 'events';

class AppEventBus extends EventEmitter {}

// Đảm bảo chỉ có 1 instance duy nhất (Singleton pattern)
// hoạt động trên toàn app
export const eventBus = new AppEventBus();

// Định nghĩa sẵn các tên sự kiện (Constants) để tái sử dụng,
// tránh gõ sai chính tả
export const appEvents = {
  INVENTORY_CHANGED: 'INVENTORY_CHANGED',
  PRODUCT_EXPIRING: 'PRODUCT_EXPIRING',
  LARGE_ORDER_CREATED: 'LARGE_ORDER_CREATED',
  BATCH_LOW_STOCK: 'BATCH_LOW_STOCK',
  BATCH_INVENTORY_CHANGED: 'BATCH_INVENTORY_CHANGED',
  INVENTORY_DISCREPANCY: 'INVENTORY_DISCREPANCY',
  REORDER_SUGGESTION: 'REORDER_SUGGESTION',
} as const;
