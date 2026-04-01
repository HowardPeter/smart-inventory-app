import { prisma } from '../../../db/prismaClient.js';
import { ProductPackageController } from '../controllers/product-package.controller.js';
import { ProductPackageRepository } from '../repositories/product-package.repository.js';
import { UnitRepository } from '../repositories/unit.repository.js';
import { ProductPackageService } from '../services/product-package.service.js';

const productPackageRepository = new ProductPackageRepository(prisma);
const unitRepository = new UnitRepository();
const productPackageService = new ProductPackageService(
  productPackageRepository,
  unitRepository,
);
const productPackageController = new ProductPackageController(
  productPackageService,
);

export {
  productPackageRepository,
  productPackageService,
  productPackageController,
};
