import {
  normalizePagination,
  buildPaginatedResponse,
} from '../../common/utils/index.js';

import type {
  SearchByKeywordQueryDto,
  ListProductPackageByKeywordResponseDto,
  ListProductByKeywordResponseDto,
  SearchByPrefixQueryDto,
  SearchProductPrefixResponseDto,
} from './search.dto.js';
import type { SearchRepository } from './search.repository.js';

export class SearchService {
  constructor(private readonly searchRepository: SearchRepository) {}

  async searchProductPackagesByKeyword(
    storeId: string,
    query: SearchByKeywordQueryDto,
  ): Promise<ListProductPackageByKeywordResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.searchRepository.searchProductPackagesByKeyword(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async searchProductsByKeyword(
    storeId: string,
    query: SearchByKeywordQueryDto,
  ): Promise<ListProductByKeywordResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } =
      await this.searchRepository.searchProductsByKeyword(storeId, {
        ...query,
        ...normalizedPagination,
      });

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async searchProductsByPrefix(
    storeId: string,
    query: SearchByPrefixQueryDto,
  ): Promise<SearchProductPrefixResponseDto[]> {
    return await this.searchRepository.searchProductsByPrefix(storeId, query);
  }
}
