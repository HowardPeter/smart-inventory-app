import { StatusCodes } from 'http-status-codes';

import {
  requireReqStoreContext,
  sendResponse,
} from '../../../common/utils/index.js';
import { InventoryAdjustmentService } from '../service/inventory-adjustment.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  ListAdjustmentsQueryDto,
  ListAdjustmentsResponseDto,
} from '../dto/inventory-adjustment.dto.js';
import type { Request, Response } from 'express';

export class InventoryAdjustmentController {
  constructor(
    private readonly inventoryAdjustmentService: InventoryAdjustmentService,
  ) {}

  getAdjustments = async (
    req: Request,
    res: Response<ApiResponse<ListAdjustmentsResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productPackageId } = req.params;

    const adjustments =
      await this.inventoryAdjustmentService.getAdjustmentsByProductPackageId(
        storeId,
        productPackageId as string,
        res.locals.validatedQuery as unknown as ListAdjustmentsQueryDto,
      );

    sendResponse.success(res, adjustments, { status: StatusCodes.OK });
  };
}
