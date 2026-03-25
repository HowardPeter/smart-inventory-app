import {
  buildPaginatedResponse,
  normalizePagination,
} from '../../../common/utils/index.js';
import { InventoryAdjustmentRepository } from '../repository/inventory-adjustment.repository.js';

import type {
  ListAdjustmentsQueryDto,
  ListAdjustmentsResponseDto,
} from '../dto/inventory-adjustment.dto.js';

export class InventoryAdjustmentService {
  constructor(
    // eslint-disable-next-line max-len
    private readonly inventoryAdjustmentRepository: InventoryAdjustmentRepository,
  ) {}

  async getAdjustmentsByProductPackageId(
    storeId: string,
    productPackageId: string,
    query: ListAdjustmentsQueryDto,
  ): Promise<ListAdjustmentsResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.inventoryAdjustmentRepository.findManyByProductPackageId(
        storeId,
        productPackageId,
        {
          ...query,
          ...normalizedPagination,
        },
      );

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }
}
