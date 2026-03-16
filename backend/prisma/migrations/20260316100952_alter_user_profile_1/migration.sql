/*
  Warnings:

  - A unique constraint covering the columns `[auth_user_id]` on the table `UserProfile` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "UserProfile_auth_user_id_key" ON "UserProfile"("auth_user_id");
