import { UnitController } from '../controllers/unit.controller.js';
import { UnitRepository } from '../repositories/unit.repository.js';
import { UnitService } from '../services/unit.service.js';

const unitRepository = new UnitRepository();
const unitService = new UnitService(unitRepository);
const unitController = new UnitController(unitService);

export { unitService, unitController };
