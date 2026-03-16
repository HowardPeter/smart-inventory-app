/*
  Warnings:

  - You are about to drop the `SyncQueue` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[barcode]` on the table `BarcodeApiCache` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[auth_user_id]` on the table `UserProfile` will be added. If there are existing duplicate values, this will fail.
  - Changed the type of `status` on the `BarcodeApiCache` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `type` on the `BarcodeApiCache` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `is_default` on the `Category` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `active_status` on the `Product` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `active_status` on the `ProductPackage` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `barcode_type` on the `ProductPackage` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `active_status` on the `Store` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `role` on the `StoreMember` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `active_status` on the `StoreMember` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `type` on the `Transaction` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `status` on the `Transaction` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Added the required column `active_status` to the `UserProfile` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "ActiveStatus" AS ENUM ('active', 'inactive');

-- CreateEnum
CREATE TYPE "StoreRole" AS ENUM ('manager', 'staff');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('import', 'export', 'adjustment');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('pending', 'completed', 'cancelled');

-- CreateEnum
CREATE TYPE "BarcodeType" AS ENUM ('upc', 'ean', 'code128', 'qr');

-- CreateEnum
CREATE TYPE "BarcodeStatus" AS ENUM ('valid', 'invalid', 'not_found');

-- DropForeignKey
ALTER TABLE "SyncQueue" DROP CONSTRAINT "SyncQueue_user_id_fkey";

-- AlterTable
ALTER TABLE "BarcodeApiCache" DROP COLUMN "status",
ADD COLUMN     "status" "BarcodeStatus" NOT NULL,
DROP COLUMN "type",
ADD COLUMN     "type" "BarcodeType" NOT NULL;

-- AlterTable
ALTER TABLE "Category" DROP COLUMN "is_default",
ADD COLUMN     "is_default" BOOLEAN NOT NULL;

-- AlterTable
ALTER TABLE "Product" DROP COLUMN "active_status",
ADD COLUMN     "active_status" "ActiveStatus" NOT NULL;

-- AlterTable
ALTER TABLE "ProductPackage" DROP COLUMN "active_status",
ADD COLUMN     "active_status" "ActiveStatus" NOT NULL,
DROP COLUMN "barcode_type",
ADD COLUMN     "barcode_type" "BarcodeType" NOT NULL;

-- AlterTable
ALTER TABLE "Store" DROP COLUMN "active_status",
ADD COLUMN     "active_status" "ActiveStatus" NOT NULL;

-- AlterTable
ALTER TABLE "StoreMember" DROP COLUMN "role",
ADD COLUMN     "role" "StoreRole" NOT NULL,
DROP COLUMN "active_status",
ADD COLUMN     "active_status" "ActiveStatus" NOT NULL;

-- AlterTable
ALTER TABLE "Transaction" DROP COLUMN "type",
ADD COLUMN     "type" "TransactionType" NOT NULL,
DROP COLUMN "status",
ADD COLUMN     "status" "TransactionStatus" NOT NULL;

-- AlterTable
ALTER TABLE "UserProfile" ADD COLUMN     "active_status" "ActiveStatus" NOT NULL;

-- DropTable
DROP TABLE "SyncQueue";

-- CreateIndex
CREATE UNIQUE INDEX "BarcodeApiCache_barcode_key" ON "BarcodeApiCache"("barcode");

-- CreateIndex
CREATE UNIQUE INDEX "UserProfile_auth_user_id_key" ON "UserProfile"("auth_user_id");
