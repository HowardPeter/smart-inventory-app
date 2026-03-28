import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';

// QUAN TRỌNG: Import Full Screen Loader của bạn
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';

class AddCategoryController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }

  Future<void> saveCategory() async {
    // 1. Kiểm tra validate form tại client (tên rỗng...)
    if (!formKey.currentState!.validate()) return;

    try {
      // 2. Hiển thị màn hình Loading phủ kính mờ chặn tương tác
      FullScreenLoaderUtils.openLoadingDialog(TTexts.savingCategory.tr);

      final payload = {
        'name': nameController.text.trim(),
        'description': descController.text.trim(),
      };

      // 3. Gọi API
      await _provider.createCategory(payload);

      // 4. Nếu thành công -> TẮT màn hình Loading
      FullScreenLoaderUtils.stopLoading();

      // 5. Thoát về trang trước
      Get.back();

      // 6. Hiển thị Snackbar thành công màu xanh lá
      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.categoryCreatedSuccessMessage.tr,
      );

      // 7. Làm mới lại danh sách ở trang Catalog ngoài kia
      if (Get.isRegistered<ProductCatalogController>()) {
        Get.find<ProductCatalogController>().fetchCategories();
      }
    } catch (e) {
      // NẾU CÓ LỖI TỪ BACKEND HOẶC MẠNG -> TẮT màn hình Loading trước
      FullScreenLoaderUtils.stopLoading();

      // Xử lý lỗi và tự động bung Snackbar báo lỗi đỏ (kèm chữ Try Again)
      handleError(e);
    }
  }
}
