import { UnitRepository } from './repositories/unit.repository.js';
import { UnitController } from './unit.controller.js';
import { UnitService } from './unit.service.js';

const unitRepository = new UnitRepository();
const unitService = new UnitService(unitRepository);
const unitController = new UnitController(unitService);

export { unitRepository, unitService, unitController };
