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

  late final CategoryModel category;

  final RxBool isLoading = true.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // Biến kiểm tra quyền Manager
  bool canManageProduct = false;

  @override
  void onInit() {
    super.onInit();

    // Kiểm tra quyền (Chỉ Manager/Owner mới được thêm sản phẩm)
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageProduct =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageProduct = false;
    }

    if (Get.arguments is CategoryModel) {
      category = Get.arguments as CategoryModel;
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
          await _provider.getProductsByCategory(category.categoryId);
      products.assignAll(fetchedData);
    } catch (e) {
      handleError(e);
    } finally {
      // LUÔN LUÔN tắt loading khi tải xong
      isLoading.value = false;
    }
  }

  // HÀM MỚI: Xử lý nút Add Product
  void addNewProduct() {
    try {
      // TODO: Mở form thêm sản phẩm
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
}
