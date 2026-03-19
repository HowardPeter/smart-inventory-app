import { CategoryService } from '../../modules/categories/services/category.service.js';

import type { Request, Response } from 'express';

const categoryService = new CategoryService();

export class CategoryController {
  async createCategory(req: Request, res: Response) {
    try {
      const { name, description, storeId } = req.body;

      const category = await categoryService.createCategory({
        name,
        description,
        storeId,
      });

      return res.status(201).json({
        success: true,
        data: category,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateCategory(req: Request, res: Response) {
    try {
      const { categoryId } = req.params;

      const updatedCategory = await categoryService.updateCategory(
        String(categoryId),
        req.body,
      );

      return res.status(200).json({
        success: true,
        data: updatedCategory,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }
  }

  async deleteCategory(req: Request, res: Response) {
    try {
      const { categoryId } = req.params;

      await categoryService.deleteCategory(String(categoryId));

      return res.status(200).json({
        success: true,
        message: 'Category deleted successfully',
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getCategories(req: Request, res: Response) {
    try {
      const { keyword, page, limit } = req.query;

      const result = await categoryService.getCategories({
        keyword: keyword as string,
        page: page ? Number(page) : undefined,
        limit: limit ? Number(limit) : undefined,
      });

      return res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }
  }
}
