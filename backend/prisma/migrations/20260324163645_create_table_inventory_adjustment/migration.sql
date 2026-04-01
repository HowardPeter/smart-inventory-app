-- CreateEnum
CREATE TYPE "AdjustmentType" AS ENUM ('set', 'increase', 'decrease');

-- CreateTable
CREATE TABLE "InventoryAdjustment" (
    "inventory_adjustment_id" TEXT NOT NULL,
    "inventory_id" TEXT NOT NULL,
    "previous_quantity" INTEGER NOT NULL,
    "current_quantity" INTEGER NOT NULL,
    "changed_quantity" INTEGER NOT NULL,
    "type" "AdjustmentType" NOT NULL,
    "reason" TEXT,
    "note" TEXT,
    "created_by" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "InventoryAdjustment_pkey" PRIMARY KEY ("inventory_adjustment_id")
);

-- AddForeignKey
ALTER TABLE "InventoryAdjustment" ADD CONSTRAINT "InventoryAdjustment_inventory_id_fkey" FOREIGN KEY ("inventory_id") REFERENCES "Inventory"("inventory_id") ON DELETE RESTRICT ON UPDATE CASCADE;
