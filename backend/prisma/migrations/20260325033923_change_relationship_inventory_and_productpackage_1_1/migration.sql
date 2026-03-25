/*
  Warnings:

  - A unique constraint covering the columns `[product_package_id]` on the table `Inventory` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "Inventory" ADD COLUMN     "active_status" "ActiveStatus" NOT NULL DEFAULT 'active';
