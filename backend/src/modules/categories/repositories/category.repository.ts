import type { DbClient } from '../../../common/types/index.js';
import type {
  CategoryResponseDto,
  CreateCategoryDto,
  UpdateCategoryDto,
} from '../category.dto.js';

export class CategoryRepository {
  constructor(private readonly db: DbClient) {}

  async findAll(storeId: string): Promise<CategoryResponseDto[]> {
    return await this.db.category.findMany({
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
    return await this.db.category.findUnique({
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

  async checkDuplicateName(storeId: string, name: string): Promise<boolean> {
    const existingCategory = await this.db.category.findFirst({
      where: {
        name: {
          equals: name,
          mode: 'insensitive', // không phân biệt hoa thường
        },
        OR: [
          {
            storeId,
            isDefault: false,
          },
          {
            isDefault: true,
            storeId: null,
          },
        ],
      },
      select: {
        categoryId: true,
      },
    });

    return !!existingCategory;
  }

  async createOne(
    storeId: string,
    payload: CreateCategoryDto,
  ): Promise<CategoryResponseDto> {
    return await this.db.category.create({
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
    return await this.db.category.update({
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

  async getUncategorizedId(): Promise<string> {
    const category = await this.db.category.findFirstOrThrow({
      where: {
        name: 'Uncategorized',
        isDefault: true,
        storeId: null,
      },
      select: {
        categoryId: true,
      },
    });

    return category.categoryId;
  }

  public async deleteCustomCategory(categoryId: string): Promise<void> {
    await this.db.category.delete({
      where: { categoryId },
    });
  }
}
