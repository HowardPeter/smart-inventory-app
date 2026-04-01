import type { UnitResponseDto } from '../product-package.dto.js';
import type { UnitRepository } from '../repositories/unit.repository.js';

export class UnitService {
  constructor(private readonly unitRepository: UnitRepository) {}

  public async getAllUnits(): Promise<UnitResponseDto[]> {
    return await this.unitRepository.findAll();
  }
}
