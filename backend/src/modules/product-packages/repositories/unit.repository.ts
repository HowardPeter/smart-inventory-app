import { prisma } from '../../../db/prismaClient.js';

import type { UnitResponseDto } from '../product-package.dto.js';

export class UnitRepository {
  async findUnitById(unitId: string): Promise<UnitResponseDto | null> {
    return await prisma.unit.findUnique({
      where: {
        unitId,
      },
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  }
  async findAll(): Promise<UnitResponseDto[]> {
    return await prisma.unit.findMany({
      select: {
        unitId: true,
        code: true,
        name: true,
      },
    });
  }
}
