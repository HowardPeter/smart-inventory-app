import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart'; // Import để update trang detail

class CategoryFormController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Biến xác định là đang Thêm mới hay Chỉnh sửa
  bool isEditMode = false;
  CategoryModel? categoryToEdit;

  @override
  void onInit() {
    super.onInit();
    // Bắt argument truyền sang. Nếu có CategoryModel thì là Edit Mode
    if (Get.arguments is CategoryModel) {
      isEditMode = true;
      categoryToEdit = Get.arguments as CategoryModel;

      // Đổ dữ liệu cũ vào Form
      nameController.text = categoryToEdit!.name;
      descController.text = categoryToEdit!.description ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }

  Future<void> saveCategory() async {
    if (!formKey.currentState!.validate()) return;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.savingCategory.tr);

      final payload = {
        'name': nameController.text.trim(),
        'description': descController.text.trim(),
      };

      if (isEditMode && categoryToEdit != null) {
        // GỌI API UPDATE
        await _provider.updateCategory(categoryToEdit!.categoryId, payload);

        FullScreenLoaderUtils.stopLoading();

        // Refresh trang Product Catalog
        if (Get.isRegistered<CategoryDetailController>()) {
          final detailCtrl = Get.find<CategoryDetailController>();

          // CẬP NHẬT TRỰC TIẾP GIÁ TRỊ VÀO RX BIẾN
          detailCtrl.rxCategory.value = CategoryModel(
            categoryId: categoryToEdit!.categoryId,
            name: payload['name']!,
            description: payload['description'],
            storeId: categoryToEdit!.storeId,
            isDefault: categoryToEdit!.isDefault,
          );
        }

        // Nếu đang mở từ trang Detail, refresh luôn trang Detail để nó cập nhật Tên/Mô tả mới
        if (Get.isRegistered<CategoryDetailController>()) {
          // Bạn có thể thiết kế lại category trong CategoryDetailController thành Rx
          // để nó tự động nhảy, hoặc chỉ cần fetch lại products.
          // Ở đây gọi back() để về trang Detail.
        }

        Get.back();
        TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.categoryUpdatedSuccessMessage.tr,
        );
      } else {
        // GỌI API CREATE (Giữ nguyên như cũ)
        await _provider.createCategory(payload);
        FullScreenLoaderUtils.stopLoading();

        if (Get.isRegistered<ProductCatalogController>()) {
          Get.find<ProductCatalogController>().fetchCategories();
        }

        Get.back();
        TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.categoryCreatedSuccessMessage.tr,
        );
      }
    } on DioException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      final statusCode = e.response?.statusCode;
      if (statusCode == 409) {
        TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr,
          message: TTexts.categoryNameExists.tr,
        );
      } else {
        handleError(e);
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }
}
