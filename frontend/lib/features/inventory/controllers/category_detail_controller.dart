import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class CategoryDetailController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  late Rx<CategoryModel> rxCategory;

  final RxBool isLoading = true.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  bool canManageProduct = false;

  @override
  void onInit() {
    super.onInit();

    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageProduct =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageProduct = false;
    }

    if (Get.arguments is CategoryModel) {
      rxCategory = (Get.arguments as CategoryModel).obs;
      fetchProducts();
    } else {
      isLoading.value = false;
      handleError("Category data is missing");
    }
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    try {
      isLoading.value = true;

      final fetchedData =
          await _provider.getProductsByCategory(rxCategory.value.categoryId);
      products.assignAll(fetchedData);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- ACTIONS CHO SẢN PHẨM ---
  void addNewProduct() {
    try {
      TSnackbarsWidget.info(
          title: TTexts.info.tr, message: TTexts.featureComingSoon.tr);
    } catch (e) {
      handleError(e);
    }
  }

  void goToProductDetail(ProductModel product) {
    try {
      Get.toNamed(
        AppRoutes.productCatalogDetail,
        arguments: product,
      );
    } catch (e) {
      handleError(e);
    }
  }

  // ==========================================
  // HÀM MỚI: ACTIONS CHO CATEGORY
  // ==========================================
  void editCategory() {
    try {
      // Chuyển sang form dùng chung và truyền category sang để bật Edit Mode
      Get.toNamed(AppRoutes.categoryForm, arguments: rxCategory.value);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteCategory() async {
    // SỬ DỤNG TCustomDialogWidget ĐỂ HIỆN XÁC NHẬN
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.deleteCategory.tr,
        description: TTexts.deleteCategoryConfirm.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () async {
          Get.back();
          try {
            FullScreenLoaderUtils.openLoadingDialog('Deleting...');

            await _provider.deleteCategory(rxCategory.value.categoryId);

            FullScreenLoaderUtils.stopLoading();

            // Refresh lại danh sách Catalog
            if (Get.isRegistered<ProductCatalogController>()) {
              Get.find<ProductCatalogController>().fetchCategories();
            }

            // Xóa xong thì đá văng người dùng về trang Product Catalog
            Get.back();

            TSnackbarsWidget.success(
              title: TTexts.successTitle.tr,
              message: TTexts.deleteCategorySuccessMessage.tr,
            );
          } on DioException catch (e) {
            FullScreenLoaderUtils.stopLoading();
            final statusCode = e.response?.statusCode;
            // Bắt đúng lỗi 409 từ Backend (Category đang chứa Products)
            if (statusCode == 409) {
              TSnackbarsWidget.warning(
                title: TTexts.errorTitle.tr,
                message: TTexts.categoryNotEmptyError.tr,
              );
            } else {
              handleError(e);
            }
          } catch (e) {
            FullScreenLoaderUtils.stopLoading();
            handleError(e);
          }
        },
      ),
      barrierDismissible: true, // Cho phép bấm ra ngoài để đóng
    );
  }
}
