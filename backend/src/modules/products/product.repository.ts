import { prisma } from '../../db/prismaClient.js';

import type {
  CreateProductData,
  UpdateProductDto,
  DetailProductResponseDto,
} from './product.dto.js';

export class ProductRepository {
  async findManyByStoreId(
    storeId: string,
  ): Promise<DetailProductResponseDto[]> {
    return await prisma.product.findMany({
      where: {
        storeId,
        activeStatus: 'active',
      },
      orderBy: {
        name: 'desc',
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
