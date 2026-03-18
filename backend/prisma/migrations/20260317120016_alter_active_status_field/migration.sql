-- AlterTable
ALTER TABLE "Product" ALTER COLUMN "active_status" SET DEFAULT 'active';

-- AlterTable
ALTER TABLE "ProductPackage" ALTER COLUMN "active_status" SET DEFAULT 'active';

-- AlterTable
ALTER TABLE "Store" ALTER COLUMN "active_status" SET DEFAULT 'active';

-- AlterTable
ALTER TABLE "StoreMember" ALTER COLUMN "active_status" SET DEFAULT 'active';

-- AlterTable
ALTER TABLE "UserProfile" ALTER COLUMN "active_status" SET DEFAULT 'active';
