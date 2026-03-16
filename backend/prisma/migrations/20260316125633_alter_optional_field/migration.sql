/*
  Warnings:

  - The `action_type` column on the `AuditLog` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "AuditActionType" AS ENUM ('create', 'update', 'delete');

-- DropForeignKey
ALTER TABLE "Category" DROP CONSTRAINT "Category_store_id_fkey";

-- AlterTable
ALTER TABLE "AuditLog" DROP COLUMN "action_type",
ADD COLUMN     "action_type" "AuditActionType",
ALTER COLUMN "entity_type" DROP NOT NULL,
ALTER COLUMN "old_value" DROP NOT NULL,
ALTER COLUMN "new_value" DROP NOT NULL;

-- AlterTable
ALTER TABLE "BarcodeApiCache" ALTER COLUMN "provider" DROP NOT NULL,
ALTER COLUMN "type" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Category" ALTER COLUMN "description" DROP NOT NULL,
ALTER COLUMN "store_id" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Inventory" ALTER COLUMN "reorder_threshold" DROP NOT NULL,
ALTER COLUMN "last_count" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Product" ALTER COLUMN "image_url" DROP NOT NULL,
ALTER COLUMN "brand" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ProductPackage" ALTER COLUMN "barcode_value" DROP NOT NULL,
ALTER COLUMN "display_name" DROP NOT NULL,
ALTER COLUMN "import_price" DROP NOT NULL,
ALTER COLUMN "selling_price" DROP NOT NULL,
ALTER COLUMN "barcode_type" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Store" ALTER COLUMN "address" DROP NOT NULL,
ALTER COLUMN "timezone" DROP NOT NULL,
ALTER COLUMN "name" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Transaction" ALTER COLUMN "note" DROP NOT NULL;

-- AlterTable
ALTER TABLE "UserProfile" ALTER COLUMN "email" DROP NOT NULL,
ALTER COLUMN "full_name" DROP NOT NULL,
ALTER COLUMN "auth_user_id" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "Category" ADD CONSTRAINT "Category_store_id_fkey" FOREIGN KEY ("store_id") REFERENCES "Store"("store_id") ON DELETE SET NULL ON UPDATE CASCADE;
