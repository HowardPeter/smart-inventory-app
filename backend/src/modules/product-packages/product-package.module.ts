import { ProductPackageController } from './product-package.controller.js';
import { ProductPackageService } from './product-package.service.js';
import { ProductPackageRepository } from './repositories/product-package.repository.js';
import { UnitRepository } from './repositories/unit.repository.js';

const productPackageRepository = new ProductPackageRepository();
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
