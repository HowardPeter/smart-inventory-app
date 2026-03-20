import { prisma } from '../../../db/prismaClient.js';

import type {
  CategoryResponseDto,
  CreateCategoryDto,
  UpdateCategoryDto,
} from '../category.dto.js';

export class CategoryRepository {
  async findAll(storeId: string): Promise<CategoryResponseDto[]> {
    return await prisma.category.findMany({
      // lấy category mặc định + không có trong hidedDefault và custom category
      where: {
        OR: [
          {
            storeId,
            isDefault: false,
          },
          {
            isDefault: true,
            storeId: null,
            hidedDefaults: {
              none: {
                storeId,
              },
            },
          },
        ],
      },
      orderBy: [
        {
          isDefault: 'desc',
        },
        {
          name: 'asc',
        },
      ],
      select: {
        categoryId: true,
        name: true,
        description: true,
        isDefault: true,
        storeId: true,
      },
    });
  }

  async findById(categoryId: string): Promise<CategoryResponseDto | null> {
    return await prisma.category.findUnique({
      where: {
        categoryId,
      },
      select: {
        categoryId: true,
        name: true,
        description: true,
        isDefault: true,
        storeId: true,
      },
    });
  }

  async createOne(
    storeId: string,
    payload: CreateCategoryDto,
  ): Promise<CategoryResponseDto> {
    return await prisma.category.create({
      data: {
        name: payload.name,
        description: payload.description,
        isDefault: false,
        storeId,
      },
      select: {
        categoryId: true,
        name: true,
        description: true,
        isDefault: true,
        storeId: true,
      },
    });
  }

  async updateOne(
    categoryId: string,
    payload: UpdateCategoryDto,
  ): Promise<CategoryResponseDto> {
    return await prisma.category.update({
      where: { categoryId },
      data: {
        ...(payload.name !== undefined && { name: payload.name }),
        ...(payload.description !== undefined && {
          description: payload.description,
        }),
      },
      select: {
        categoryId: true,
        name: true,
        description: true,
        isDefault: true,
        storeId: true,
      },
    });
  }

  public async countProductsByCategoryId(categoryId: string): Promise<number> {
    return await prisma.product.count({
      where: {
        categoryId,
      },
    });
  }

  public async deleteCustomCategory(categoryId: string): Promise<void> {
    await prisma.category.delete({
      where: { categoryId },
    });
  }
}
