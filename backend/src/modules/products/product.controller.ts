import { StatusCodes } from 'http-status-codes';

import { ProductService } from './product.service.js';
import {
  requireReqStoreContext,
  requireReqUser,
  sendResponse,
} from '../../common/utils/index.js';

import type {
  CreateProductDto,
  CreateProductData,
  ProductResponseDto,
  UpdateProductDto,
  ListProductsQueryDto,
  ListProductsResponseDto,
} from './product.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class ProductController {
  constructor(private readonly productService: ProductService) {}

  getProducts = async (
    req: Request,
    res: Response<ApiResponse<ListProductsResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const products = await this.productService.getProductsbyStoreId(
      storeId,
      res.locals.validatedQuery as unknown as ListProductsQueryDto,
    );

    sendResponse.success(res, products, { status: StatusCodes.OK });
  };

  getProductById = async (
    req: Request,
    res: Response<ApiResponse<ProductResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productId } = req.params;

    const product = await this.productService.getProductById(
      storeId,
      productId as string,
    );

    sendResponse.success(res, product, { status: StatusCodes.OK });
  };

  createProduct = async (
    req: Request,
    res: Response<ApiResponse<ProductResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const newProductData: CreateProductData = {
      ...(req.body as CreateProductDto),
      storeId,
    };

    const product = await this.productService.createProduct(
      storeId,
      userId,
      newProductData,
    );

    sendResponse.success(res, product, { status: StatusCodes.CREATED });
  };

  updateProduct = async (
    req: Request,
    res: Response<ApiResponse<ProductResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productId } = req.params;

    const product = await this.productService.updateProduct(
      storeId,
      userId,
      productId as string,
      req.body as UpdateProductDto,
    );

    sendResponse.success(res, product, { status: StatusCodes.OK });
  };

  softDeleteProduct = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productId } = req.params;

    await this.productService.softDeleteProduct(
      storeId,
      userId,
      productId as string,
    );

    sendResponse.success(res, null, { status: StatusCodes.OK });
  };
}
