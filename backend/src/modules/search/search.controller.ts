import { StatusCodes } from 'http-status-codes';

import { SearchService } from './search.service.js';
import {
  requireReqStoreContext,
  sendResponse,
} from '../../common/utils/index.js';

import type {
  SearchByKeywordQueryDto,
  ListSearchByKeywordResponseDto,
  SearchByPrefixQueryDto,
  SearchProductPrefixResponseDto,
} from './search.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  getProductsbyKeyword = async (
    req: Request,
    res: Response<ApiResponse<ListSearchByKeywordResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const searchedProducts = await this.searchService.searchProductsByKeyword(
      storeId,
      res.locals.validatedQuery as unknown as SearchByKeywordQueryDto,
    );

    sendResponse.success(res, searchedProducts, { status: StatusCodes.OK });
  };

  getProductsByPrefix = async (
    req: Request,
    res: Response<ApiResponse<SearchProductPrefixResponseDto[]>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const searchedProducts = await this.searchService.searchProductsByPrefix(
      storeId,
      res.locals.validatedQuery as unknown as SearchByPrefixQueryDto,
    );

    sendResponse.success(res, searchedProducts, { status: StatusCodes.OK });
  };
}
