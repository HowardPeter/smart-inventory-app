/*
  Warnings:

  - You are about to drop the `InventoryAdjustment` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "InventoryAdjustment" DROP CONSTRAINT "InventoryAdjustment_inventory_id_fkey";

-- DropTable
DROP TABLE "InventoryAdjustment";

-- DropEnum
DROP TYPE "AdjustmentType";
