import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart'; // Đừng quên import

class AllProductsController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  final RxBool isLoading = true.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxString activeCategory = TTexts.allItems.obs;

  bool canManageProduct = false;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    debounce(searchQuery, (_) => update(),
        time: const Duration(milliseconds: 300));
    fetchData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _checkPermissions() {
    try {
      final storeService = Get.find<StoreService>();
      final role = storeService.currentRole.value.toLowerCase();
      canManageProduct =
          (role == 'manager' || role == 'owner' || role == 'admin');
    } catch (e) {
      canManageProduct = false;
    }
  }

  // ==========================================
  // API CALLS
  // ==========================================
  Future<void> fetchData({bool isRefresh = false}) async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _provider.getProducts(),
        _provider.getCategories(),
      ]);

      allProducts.assignAll(results[0] as List<ProductModel>);
      categories.assignAll(results[1] as List<CategoryModel>);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // REFRESH DATA
  // ==========================================
  Future<void> refreshData() async {
    await fetchData(isRefresh: true);
  }

  // ==========================================
  // LOGIC TÌM KIẾM & LỌC
  // ==========================================
  List<ProductModel> get filteredProducts {
    List<ProductModel> result = allProducts.toList();

    // 1. Lọc theo danh mục trước (Nếu không phải là "All")
    if (activeCategory.value != TTexts.allItems) {
      // Tìm ID của category đang được chọn
      final selectedCatId = categories
          .firstWhereOrNull((c) => c.name == activeCategory.value)
          ?.categoryId;

      if (selectedCatId != null) {
        result = result.where((p) => p.categoryId == selectedCatId).toList();
      }
    }

    // 2. Lọc theo từ khóa tìm kiếm
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((product) {
        final name = product.name.toLowerCase();
        final brand = product.brand?.toLowerCase() ?? '';
        return name.contains(query) || brand.contains(query);
      }).toList();
    }

    return result;
  }

  // Hàm xử lý khi bấm vào Chip
  void setCategory(String categoryName) {
    activeCategory.value = categoryName;
    update(); // Kích hoạt vẽ lại UI
  }

  // ==========================================
  // ĐIỀU HƯỚNG
  // ==========================================
  void goToProductDetail(ProductModel product) {
    try {
      Get.toNamed(AppRoutes.productCatalogDetail, arguments: product);
    } catch (e) {
      handleError(e);
    }
  }
}
