/*
  Warnings:

  - You are about to drop the column `last_login` on the `UserProfile` table. All the data in the column will be lost.
  - You are about to drop the column `username` on the `UserProfile` table. All the data in the column will be lost.
  - Added the required column `auth_user_id` to the `UserProfile` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `UserProfile` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Inventory" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "Product" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "ProductPackage" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "Store" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "UserProfile" DROP COLUMN "last_login",
DROP COLUMN "username",
ADD COLUMN     "auth_user_id" TEXT NOT NULL,
ADD COLUMN     "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;
