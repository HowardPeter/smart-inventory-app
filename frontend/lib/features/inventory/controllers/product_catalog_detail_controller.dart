import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart'; // THÊM MODEL INVENTORY
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';

// THÊM CONTROLLER ĐỂ REFRESH TỰ ĐỘNG
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';

class ProductCatalogDetailController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  late final ProductModel product;

  // CÁC BIẾN OBSERVE ĐỂ CẬP NHẬT UI TỨC THÌ
  final RxString rxName = ''.obs;
  final RxString rxBrand = ''.obs;
  final RxString rxImageUrl = ''.obs;

  final RxBool isLoadingPackages = true.obs;
  final RxList<ProductPackageModel> packages = <ProductPackageModel>[].obs;

  bool _isDeleteDialogShowing = false;
  bool canManageProduct = false;

  @override
  void onInit() {
    super.onInit();
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageProduct = (role == 'manager');
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
      handleError(TTexts.productDataMissing.tr);
      Get.back();
    }
  }

  Future<void> fetchPackages({bool isRefresh = false}) async {
    try {
      // 1. ÉP LUÔN LUÔN BẬT LOADING ĐỂ SHIMMER CHẠY CẢ KHI PULL-TO-REFRESH
      isLoadingPackages.value = true;

      // Tạo độ trễ nhỏ để trải nghiệm mượt mà không bị chớp giật
      if (isRefresh) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final results = await Future.wait([
        _provider.getPackagesByProduct(product.productId),
        _provider.getInventories(),
      ]);

      final fetchedPackages = results[0] as List<ProductPackageModel>;
      final allInventories = results[1] as List<InventoryModel>;

      // 2. DÙNG BLACKLIST: Lấy ra những ID CHẮC CHẮN ĐÃ BỊ INACTIVE TRONG KHO
      final deadInventoryPackageIds = allInventories
          .where((inv) => (inv.activeStatus).toLowerCase() == 'inactive')
          .map((inv) => inv.productPackageId)
          .toSet();

      // 3. LỌC: Package phải 'active' VÀ không nằm trong sổ đen của kho
      final validPackages = fetchedPackages.where((p) {
        final isPackageActive = (p.activeStatus).toLowerCase() == 'active';
        final isInventoryDead =
            deadInventoryPackageIds.contains(p.productPackageId);

        return isPackageActive && !isInventoryDead;
      }).toList();

      packages.assignAll(validPackages);
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
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.productNotEmptyError.tr);
      return;
    }

    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.deleteProduct.tr,
        description: TTexts.confirmMoveProductToTrash.tr,
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

            // Báo cho các màn hình Tổng update
            if (Get.isRegistered<InventoryController>()) {
              Get.find<InventoryController>()
                  .fetchDashboardData(isRefresh: true);
            }
            if (Get.isRegistered<InventoryInsightController>()) {
              Get.find<InventoryInsightController>().refreshData();
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
    // 1. CHẶN NGAY NẾU ĐANG CÓ DIALOG MỞ
    if (_isDeleteDialogShowing) return;

    // 2. CHẶN SLIDABLE GỌI LẠI ITEM ĐÃ XÓA
    if (!packages.any((p) => p.productPackageId == package.productPackageId)) {
      return;
    }

    _isDeleteDialogShowing = true;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final int currentQuantity =
          await _provider.getPackageQuantity(package.productPackageId);

      FullScreenLoaderUtils.stopLoading();

      if (currentQuantity > 0) {
        await Get.dialog(
          TCustomDialogWidget(
            title: TTexts.inventoryNotEmptyTitle.tr,
            description:
                '${TTexts.inventoryNotEmptyMessage.tr}\n\n(${TTexts.currentStockWithCount.trParams({
                  'count': currentQuantity.toString()
                })})',
            icon: const Text('📦', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.makeTransaction.tr,
            secondaryButtonText: TTexts.cancel.tr,
            onSecondaryPressed: () => Get.back(),
            onPrimaryPressed: () {
              // TODO: Điều hướng sang trang tạo Transaction
              Get.back();
              TSnackbarsWidget.info(
                  title: 'Info', message: 'Navigate to Transaction page');
            },
          ),
          barrierDismissible: false,
        );
        return;
      }

      final bool? shouldDelete = await Get.dialog<bool>(
        TCustomDialogWidget(
          title: TTexts.deletePackage.tr,
          description:
              '${TTexts.confirmDeletePackageMessage.tr}\n(${package.displayName})',
          icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.delete.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onSecondaryPressed: () => Get.back(result: false),
          onPrimaryPressed: () => Get.back(result: true),
        ),
        barrierDismissible: false,
      );

      if (shouldDelete == true) {
        await _performDeletePackage(package.productPackageId);
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isDeleteDialogShowing = false;
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

      // 🟢 BÁO CHO CÁC TRANG KIA TỰ ĐỘNG CẬP NHẬT KHI XÓA THÀNH CÔNG 🟢
      if (Get.isRegistered<InventoryController>()) {
        Get.find<InventoryController>().fetchDashboardData(isRefresh: true);
      }
      if (Get.isRegistered<InventoryInsightController>()) {
        Get.find<InventoryInsightController>().refreshData();
      }
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
