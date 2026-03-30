import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';

class ProductCatalogDetailController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  late final ProductModel product;

  // CÁC BIẾN OBSERVE ĐỂ CẬP NHẬT UI TỨC THÌ
  final RxString rxName = ''.obs;
  final RxString rxBrand = ''.obs;
  final RxString rxImageUrl = ''.obs;

  final RxBool isLoadingPackages = true.obs;
  final RxList<ProductPackageModel> packages = <ProductPackageModel>[].obs;

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

    if (Get.arguments is ProductModel) {
      product = Get.arguments as ProductModel;
      rxName.value = product.name;
      rxBrand.value = product.brand ?? '';
      rxImageUrl.value = product.imageUrl ?? '';
      fetchPackages();
    } else {
      // ĐÃ SỬA THÀNH TTexts
      handleError(TTexts.productDataMissing.tr);
      Get.back();
    }
  }

  Future<void> fetchPackages({bool isRefresh = false}) async {
    try {
      isLoadingPackages.value = true;
      final fetchedData =
          await _provider.getPackagesByProduct(product.productId);

      // Chỉ hiển thị các package đang active
      packages.assignAll(
          fetchedData.where((p) => p.activeStatus == 'active').toList());
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingPackages.value = false;
    }
  }

  void updateLocalInfo({String? name, String? brand, String? imageUrl}) {
    if (name != null) rxName.value = name;
    if (brand != null) rxBrand.value = brand;
    if (imageUrl != null) rxImageUrl.value = imageUrl;
  }

  void updateLocalPackage(ProductPackageModel updatedPkg) {
    final index = packages
        .indexWhere((p) => p.productPackageId == updatedPkg.productPackageId);
    if (index != -1) {
      packages[index] = updatedPkg;
      packages.refresh();
    } else {
      packages.insert(0, updatedPkg);
      packages.refresh();
    }
  }

  // ==========================================
  // ACTIONS CHO PRODUCT GỐC
  // ==========================================
  void editProductInfo() {
    Get.toNamed(AppRoutes.productForm,
        arguments: {'product': product, 'mode': 'info'});
  }

  void editProductImage() {
    Get.toNamed(AppRoutes.productForm,
        arguments: {'product': product, 'mode': 'image'});
  }

  void deleteProduct() {
    if (packages.isNotEmpty) {
      // ĐÃ SỬA THÀNH TTexts
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.productNotEmptyError.tr);
      return;
    }

    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.deleteProduct.tr,
        description: TTexts.confirmMoveProductToTrash.tr, // ĐÃ SỬA THÀNH TTexts
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () async {
          Get.back();
          try {
            FullScreenLoaderUtils.openLoadingDialog(TTexts.deletingProduct.tr);

            await _provider.deleteProduct(product.productId);

            FullScreenLoaderUtils.stopLoading();

            if (Get.isRegistered<CategoryDetailController>()) {
              Get.find<CategoryDetailController>()
                  .fetchProducts(isRefresh: true);
            }

            Get.back();
            Future.delayed(const Duration(milliseconds: 300), () {
              TSnackbarsWidget.success(
                  title: TTexts.successTitle.tr,
                  message: TTexts.productDeletedSuccess.tr);
            });
          } on DioException catch (e) {
            FullScreenLoaderUtils.stopLoading();
            TSnackbarsWidget.error(
                title: TTexts.errorTitle.tr,
                message: e.response?.data?['message'] ??
                    TTexts.errorUnknownMessage.tr);
          } catch (e) {
            FullScreenLoaderUtils.stopLoading();
            handleError(e);
          }
        },
      ),
    );
  }

  // ==========================================
  // ACTIONS CHO PACKAGES
  // ==========================================
  void addNewPackage() {
    Get.toNamed(AppRoutes.productForm,
        arguments: {'product': product, 'mode': 'add_package'});
  }

  void editPackage(ProductPackageModel package) {
    Get.toNamed(AppRoutes.productForm, arguments: {
      'product': product,
      'package': package,
      'mode': 'edit_package'
    });
  }

  void deletePackage(ProductPackageModel package) async {
    try {
      // 1. HIỆN LOADING KHI ĐANG CHECK KHO
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      // 2. LẤY SỐ LƯỢNG TỒN KHO THỰC TẾ
      final int currentQuantity =
          await _provider.getPackageQuantity(package.productPackageId);

      FullScreenLoaderUtils.stopLoading();

      // 3. NẾU CÒN HÀNG TRONG KHO (> 0) -> CHẶN XÓA
      if (currentQuantity > 0) {
        Get.dialog(
          TCustomDialogWidget(
            title: TTexts.inventoryNotEmptyTitle.tr,
            // ĐÃ SỬA: Không còn text cứng, sử dụng trParams
            description:
                '${TTexts.inventoryNotEmptyMessage.tr}\n\n(${TTexts.currentStockWithCount.trParams({
                  'count': currentQuantity.toString()
                })})',
            icon: const Text('📦', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.makeTransaction.tr,
            secondaryButtonText: TTexts.cancel.tr,
            onSecondaryPressed: () => Get.back(),
            onPrimaryPressed: () {
              Get.back();
              // TODO: Điều hướng sang trang tạo Transaction
              TSnackbarsWidget.info(
                  title: 'Info', message: 'Navigate to Transaction page');
            },
          ),
        );
        return;
      }

      // 4. NẾU KHO ĐÃ TRỐNG (= 0) -> HIỆN DIALOG XÁC NHẬN XÓA
      Get.dialog(
        TCustomDialogWidget(
          title: TTexts.deletePackage.tr,
          description:
              '${TTexts.confirmDeletePackageMessage.tr}\n(${package.displayName})',
          icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.delete.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onSecondaryPressed: () => Get.back(),
          onPrimaryPressed: () async {
            Get.back(); // Đóng dialog xác nhận
            _performDeletePackage(package.productPackageId);
          },
        ),
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  // Hàm phụ thực hiện lệnh gọi API xóa
  Future<void> _performDeletePackage(String packageId) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.deletingPackage.tr);
      await _provider.deleteProductPackage(packageId);
      FullScreenLoaderUtils.stopLoading();

      packages.removeWhere((p) => p.productPackageId == packageId);
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.packageDeletedSuccess.tr);
    } on DioException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message:
              e.response?.data?['message'] ?? TTexts.errorUnknownMessage.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }
}
