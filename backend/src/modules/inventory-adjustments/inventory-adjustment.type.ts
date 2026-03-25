export type AdjustmentType = 'set' | 'increase' | 'decrease';

export type InventoryAdjustment = {
  inventoryAdjustmentId: string;
  inventoryId: string;
  previousQuantity: number;
  currentQuantity: number;
  changedQuantity: number;
  type: AdjustmentType;
  reason: string | null;
  note: string | null;
  createdBy: string;
  createdAt: Date;
};
