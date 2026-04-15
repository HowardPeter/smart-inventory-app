import { appEvents, eventBus } from '../../common/events/event-bus.js';

interface BatchInventoryPayload {
  storeId: string;
  items: Array<{
    inventoryId: string;
    oldQuantity: number;
    newQuantity: number;
  }>;
}

interface SingleInventoryPayload {
  inventoryId: string;
  storeId: string;
  oldQuantity: number;
  newQuantity: number;
}

export class InventoryEventPublisher {
  // Phát sự kiện đơn lẻ
  public emitInventoryChanged(payload: SingleInventoryPayload): void {
    console.info(
      `[Event Publisher] Bắn sự kiện INVENTORY_CHANGED cho kho ${payload.inventoryId}. Từ ${payload.oldQuantity} -> ${payload.newQuantity}`,
    );
    eventBus.emit(appEvents.INVENTORY_CHANGED, payload);
  }
  // Hàm phát sự kiện gộp
  public emitBatchInventoryChanged(payload: BatchInventoryPayload): void {
    console.info(
      `[Event Publisher] Bắn sự kiện BATCH_INVENTORY_CHANGED cho cửa hàng ${payload.storeId} với ${payload.items.length} sản phẩm.`,
    );
    eventBus.emit(appEvents.BATCH_INVENTORY_CHANGED, payload);
  }
}
