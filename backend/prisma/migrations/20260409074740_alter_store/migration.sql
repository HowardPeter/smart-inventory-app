/*
  Warnings:

  - A unique constraint covering the columns `[invite_code]` on the table `Store` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "Store" ADD COLUMN     "invite_code" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Store_invite_code_key" ON "Store"("invite_code");
