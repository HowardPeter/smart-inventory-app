/*
  Warnings:

  - Added the required column `active_status` to the `UserProfile` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "UserProfile" ADD COLUMN     "active_status" TEXT NOT NULL;
