import { Router } from 'express';

import { CategoryController } from '../categories/category.controller.js';

const router = Router();
const controller = new CategoryController();

router.get('/', controller.getCategories);
router.post('/', controller.createCategory);
router.patch('/:categoryId', controller.updateCategory);
router.delete('/:categoryId', controller.deleteCategory);

export default router;
