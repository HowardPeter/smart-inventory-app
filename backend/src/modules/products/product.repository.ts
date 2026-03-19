import {
  normalizePagination,
  getPaginationSkip,
} from '../../common/utils/index.js';
import { prisma } from '../../db/prismaClient.js';

import type {
  CreateProductData,
  UpdateProductDto,
  DetailProductResponseDto,
  ListProductsQueryDto,
  ProductListItemDto,
} from './product.dto.js';
import type { Prisma } from '../../../src/generated/prisma/client.js';

export class ProductRepository {
  async findManyByStoreId(
    storeId: string,
    query: ListProductsQueryDto,
  ): Promise<{ items: ProductListItemDto[]; totalItems: number }> {
    const { page, limit } = normalizePagination(query);
    const { sortBy = 'name', sortOrder = 'desc', categoryId, brand } = query;

    const where: Prisma.ProductWhereInput = {
      storeId,
      activeStatus: 'active',

      // nếu có giá trị thì thêm, undefined thì thôi
      ...(categoryId && { categoryId }),
      ...(brand && {
        brand: {
          equals: brand,
          mode: 'insensitive', // không phân biệt hoa thường
        },
      }),
    };

    // INFO: $transaction - chạy nhiều query trong 1 transaction
    const [items, totalItems] = await prisma.$transaction([
      prisma.product.findMany({
        where,
        orderBy: {
          [sortBy]: sortOrder,
        },
        skip: getPaginationSkip({ page, limit }),
        take: limit,
        select: {
          productId: true,
          name: true,
          imageUrl: true,
          brand: true,
          activeStatus: true,
          createdAt: true,
          updatedAt: true,
          storeId: true,
          category: {
            select: {
              categoryId: true,
              name: true,
              description: true,
            },
          },
        },
      }),
      prisma.product.count({
        where,
      }),
    ]);

    return {
      items,
      totalItems,
    };
  }

  async findOne(
    storeId: string,
    productId: string,
  ): Promise<DetailProductResponseDto | null> {
    return await prisma.product.findFirst({
      where: {
        productId,
        storeId,
        activeStatus: 'active',
      },
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        activeStatus: true,
        createdAt: true,
        updatedAt: true,
        storeId: true,
        category: {
          select: {
            categoryId: true,
            name: true,
            description: true,
          },
        },
      },
    });
  }

  async createOne(data: CreateProductData): Promise<DetailProductResponseDto> {
    return await prisma.product.create({
      data,
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        activeStatus: true,
        createdAt: true,
        updatedAt: true,
        storeId: true,
        category: {
          select: {
            categoryId: true,
            name: true,
            description: true,
          },
        },
      },
    });
  }

  async updateOne(
    productId: string,
    data: UpdateProductDto,
  ): Promise<DetailProductResponseDto> {
    return await prisma.product.update({
      where: { productId },
      data,
      select: {
        productId: true,
        name: true,
        imageUrl: true,
        brand: true,
        activeStatus: true,
        createdAt: true,
        updatedAt: true,
        storeId: true,
        category: {
          select: {
            categoryId: true,
            name: true,
            description: true,
          },
        },
      },
    });
  }

  async softDeleteOne(productId: string): Promise<void> {
    await prisma.product.update({
      where: {
        productId,
      },
      data: {
        activeStatus: 'inactive',
      },
    });
  }
}
