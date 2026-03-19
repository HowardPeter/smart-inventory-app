import { prisma } from '../../../db/prismaClient.js';

import type { CategoryResponseDTO } from '../dtos/category.dto.js';
import type { CreateCategoryDTO } from '../dtos/create-category.dto.js';
import type { GetCategoriesDTO } from '../dtos/get-category.dto.js';
import type { UpdateCategoryDTO } from '../dtos/update-category.dto.js';

export class CategoryRepository {
  async createCategory(data: CreateCategoryDTO) {
    if (data.storeId) {
      const store = await prisma.store.findUnique({
        where: { storeId: data.storeId },
      });

      if (!store) {
        throw new Error('Store not found');
      }
    }

    return prisma.category.create({
      data: {
        name: data.name,
        description: data.description ?? null,
        storeId: data.storeId ?? null,
        isDefault: false,
      },
    });
  }

  async findByName(name: string, storeId?: string) {
    return prisma.category.findFirst({
      where: {
        name,
        ...(storeId ? { storeId } : {}),
      },
    });
  }

  async findById(categoryId: string) {
    return prisma.category.findUnique({
      where: { categoryId },
    });
  }

  async updateCategory(categoryId: string, data: UpdateCategoryDTO) {
    return prisma.category.update({
      where: { categoryId },
      data: {
        ...(data.name && { name: data.name }),
        ...(data.description !== undefined && {
          description: data.description ?? null,
        }),
      },
    });
  }

  async countProducts(categoryId: string) {
    return prisma.product.count({
      where: {
        categoryId,
      },
    });
  }

  async deleteCategory(categoryId: string) {
    return prisma.category.delete({
      where: { categoryId },
    });
  }

  async getCategories(query: GetCategoriesDTO) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;

    const skip = (page - 1) * limit;

    const where = {
      ...(query.keyword && {
        name: {
          contains: query.keyword,
          mode: 'insensitive' as const,
        },
      }),
    };

    const [categories, total] = await Promise.all([
      prisma.category.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          name: 'asc',
        },
      }),

      prisma.category.count({
        where,
      }),
    ]);

    return {
      data: categories,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(categoryId: string): Promise<CategoryResponseDTO | null> {
    return await prisma.category.findFirst({
      where: { categoryId },
      select: {
        categoryId: true,
        name: true,
        description: true,
        isDefault: true,
        storeId: true,
      },
    });
  }
}
