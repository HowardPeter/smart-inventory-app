import { StatusCodes } from 'http-status-codes';

import { sendResponse } from '../../../common/utils/index.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type { UnitResponseDto } from '../product-package.dto.js';
import type { UnitService } from '../services/unit.service.js';
import type { Request, Response } from 'express';

export class UnitController {
  constructor(private readonly unitService: UnitService) {}

  getUnits = async (
    _req: Request,
    res: Response<ApiResponse<UnitResponseDto[]>>,
  ): Promise<void> => {
    const units = await this.unitService.getAllUnits();

    sendResponse.success(res, units, { status: StatusCodes.OK });
  };
}
