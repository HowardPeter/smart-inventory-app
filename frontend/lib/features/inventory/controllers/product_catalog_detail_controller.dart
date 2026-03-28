import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart'; // ĐÃ THÊM
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';

class ProductCatalogDetailController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  late final ProductModel product;

  // Quản lý state của danh sách Packages
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
      fetchPackages(); // Bắt đầu load các packages liên quan
    } else {
      handleError("Product data is missing");
      Get.back();
    }
  }

  // LẤY DANH SÁCH PACKAGES
  Future<void> fetchPackages({bool isRefresh = false}) async {
    try {
      isLoadingPackages.value = true;

      final fetchedData =
          await _provider.getPackagesByProduct(product.productId);
      packages.assignAll(fetchedData);
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingPackages.value = false;
    }
  }

  // --- ACTIONS CHO PRODUCT GỐC ---
  void editProduct() {
    TSnackbarsWidget.info(
        title: TTexts.editProduct.tr, message: TTexts.featureComingSoon.tr);
  }

  void deleteProduct() {
    TSnackbarsWidget.warning(
        title: TTexts.deleteProduct.tr, message: TTexts.featureComingSoon.tr);
  }

  // --- ACTIONS CHO PACKAGES ---
  void addNewPackage() {
    TSnackbarsWidget.info(
        title: TTexts.addNewPackage.tr, message: TTexts.featureComingSoon.tr);
  }

  void editPackage(ProductPackageModel package) {
    TSnackbarsWidget.info(
        title: TTexts.editPackage.tr,
        message: '${TTexts.editPackage.tr} ${package.displayName}');
  }
}
