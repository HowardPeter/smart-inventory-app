import {
  normalizePagination,
  buildPaginatedResponse,
} from '../../common/utils/index.js';

import type {
  SearchByKeywordQueryDto,
  ListSearchByKeywordResponseDto,
  SearchByPrefixQueryDto,
  SearchProductPrefixResponseDto,
} from './search.dto.js';
import type { SearchRepository } from './search.repository.js';

export class SearchService {
  constructor(private readonly searchRepository: SearchRepository) {}

  async searchProductsByKeyword(
    storeId: string,
    query: SearchByKeywordQueryDto,
  ): Promise<ListSearchByKeywordResponseDto> {
    const normalizedPagination = normalizePagination(query);

    const { items, totalItems } = await this.searchRepository.searchByKeyword(
      storeId,
      {
        ...query,
        ...normalizedPagination,
      },
    );

    return buildPaginatedResponse(items, totalItems, normalizedPagination);
  }

  async searchProductsByPrefix(
    storeId: string,
    query: SearchByPrefixQueryDto,
  ): Promise<SearchProductPrefixResponseDto[]> {
    return await this.searchRepository.searchByPrefix(storeId, query);
  }
}
