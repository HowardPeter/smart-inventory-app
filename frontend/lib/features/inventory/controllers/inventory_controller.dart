import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/dashboard_stat_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/inventory_provider.dart';

class InventoryController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();
  final _box = GetStorage();

  // --- Dữ liệu gốc từ API ---
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;
  final RxList<CategoryStatModel> categoryStats = <CategoryStatModel>[].obs;
  final RxList<DistributionModel> topDistribution = <DistributionModel>[].obs;

  // Biến lưu thứ tự Custom Catalog
  final RxList<String> customCategoryOrder = <String>[].obs;

  final RxBool isLoading = true.obs;

  // --- Các chỉ số phái sinh cho Dashboard ---
  final RxInt totalActiveProducts = 0.obs;
  final RxDouble totalStockValue = 0.0.obs;

  // Health
  final RxDouble stockHealthPercent = 0.0.obs;
  final RxInt healthyCount = 0.obs;
  final RxInt lowCount = 0.obs;
  final RxInt outCount = 0.obs;

  // Flow Chart (MOCK DATA: 7 ngày gần nhất)
  final RxList<double> inboundFlow = <double>[].obs;
  final RxList<double> outboundFlow = <double>[].obs;
  final RxInt weeklyInbound = 0.obs;
  final RxInt weeklyOutbound = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomOrder();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData({bool isRefresh = false}) async {
    try {
      isLoading.value = true;

      if (isRefresh) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final results = await Future.wait([
        _provider.getCategories(),
        _provider.getProducts(),
        _provider.getInventories(),
      ]);

      final fetchedCategories = results[0] as List<CategoryModel>;
      final fetchedProducts = results[1] as List<ProductModel>;
      final fetchedInventories = results[2] as List<InventoryModel>;

      final validCategoryIds =
          fetchedCategories.map((c) => c.categoryId).toSet();

      final validProducts = fetchedProducts
          .where((p) => validCategoryIds.contains(p.categoryId))
          .toList();
      final validProductIds = validProducts.map((p) => p.productId).toSet();

      final activeInventories = fetchedInventories.where((inv) {
        final pkg = inv.productPackage;
        if (pkg == null) return false;

        if ((pkg.activeStatus).toLowerCase() != 'active') return false;
        if ((inv.activeStatus).toLowerCase() == 'inactive') return false;

        if (!validProductIds.contains(pkg.productId)) return false;

        return true;
      }).toList();

      categories.assignAll(fetchedCategories);
      products.assignAll(validProducts);
      inventories.assignAll(activeInventories);

      _calculateDashboardInsights();
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _loadCustomOrder() {
    List<dynamic>? saved = _box.read<List<dynamic>>(_customOrderKey);

    if (saved != null) {
      customCategoryOrder.assignAll(saved.cast<String>());
    } else {
      customCategoryOrder.clear();
    }
  }

  void saveCustomOrder(List<String> newOrder) {
    customCategoryOrder.assignAll(newOrder);
    _box.write(_customOrderKey, newOrder);
    _calculateDashboardInsights();
  }

  String get _customOrderKey {
    try {
      final storeService = Get.find<StoreService>();
      final userService = Get.find<UserService>();

      final storeId = storeService.currentStoreId.value;
      final userId = userService.currentUser.value?.userId ?? 'unknown_user';

      if (storeId.isEmpty) return 'custom_category_order_default';

      return 'custom_category_order_${storeId}_$userId';
    } catch (e) {
      return 'custom_category_order_default';
    }
  }

  void _calculateDashboardInsights() {
    // 1. Gán số liệu cơ bản
    totalActiveProducts.value = inventories.length;

    double tempValue = 0.0;
    int hCount = 0;
    int lCount = 0;
    int oCount = 0;

    for (var inv in inventories) {
      if (inv.productPackage != null) {
        tempValue += (inv.quantity * inv.productPackage!.importPrice);
      }

      if (inv.quantity == 0) {
        oCount++;
      } else if (inv.quantity <= inv.reorderThreshold) {
        lCount++;
      } else {
        hCount++;
      }
    }

    totalStockValue.value = tempValue;
    healthyCount.value = hCount;
    lowCount.value = lCount;
    outCount.value = oCount;

    final totalInventories = hCount + lCount + oCount;
    if (totalInventories > 0) {
      stockHealthPercent.value = (hCount / totalInventories) * 100;
    } else {
      stockHealthPercent.value = 0.0;
    }

    List<CategoryStatModel> tempCatStats = [];
    List<DistributionModel> tempDist = [];
    int maxDistValue = 0;

    for (var cat in categories) {
      int pCount = products.where((p) => p.categoryId == cat.categoryId).length;
      tempCatStats.add(CategoryStatModel(name: cat.name, count: pCount));

      int totalQty = 0;
      final catProductIds = products
          .where((p) => p.categoryId == cat.categoryId)
          .map((p) => p.productId)
          .toList();

      for (var inv in inventories) {
        if (inv.productPackage != null &&
            catProductIds.contains(inv.productPackage!.productId)) {
          totalQty += inv.quantity;
        }
      }

      if (totalQty > maxDistValue) maxDistValue = totalQty;
      tempDist.add(DistributionModel(name: cat.name, value: totalQty, max: 1));
    }

    // =========================================================
    // 🟢 ĐOẠN CẬP NHẬT: SẮP XẾP DANH MỤC THÔNG MINH
    // =========================================================
    tempCatStats.sort((a, b) {
      // 1. Tìm thông tin gốc từ danh sách `categories` để xem nó có phải là Mặc định (isDefault) không
      final catA = categories.firstWhereOrNull((c) => c.name == a.name);
      final catB = categories.firstWhereOrNull((c) => c.name == b.name);

      final isDefaultA = catA?.isDefault ?? false;
      final isDefaultB = catB?.isDefault ?? false;

      // Ưu tiên 1: Đẩy những thằng Mặc định (Uncategorized) lên Top đầu tiên
      if (isDefaultA && !isDefaultB) return -1;
      if (!isDefaultA && isDefaultB) return 1;

      // 2. Tìm vị trí của Category trong mảng customOrder (nếu có)
      int indexA = customCategoryOrder.indexOf(a.name);
      int indexB = customCategoryOrder.indexOf(b.name);

      // Ưu tiên 2: Xếp theo thứ tự Custom kéo thả
      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;

      // Ưu tiên 3: Xắp xếp theo Bảng chữ cái (Default)
      return a.name.compareTo(b.name);
    });

    categoryStats.value = tempCatStats;
    // =========================================================

    // Lọc ra Top 5 danh mục có Volume lớn nhất (giảm dần)
    tempDist.sort((a, b) => b.value.compareTo(a.value));
    topDistribution.value = tempDist.take(5).map((e) {
      return DistributionModel(
          name: e.name,
          value: e.value,
          max: maxDistValue == 0 ? 1 : maxDistValue);
    }).toList();

    // --- MOCK DATA CHO FLOW CHART ---
    inboundFlow.value = [12, 18, 15, 25, 22, 30, 28];
    outboundFlow.value = [8, 15, 10, 20, 18, 25, 22];

    weeklyInbound.value =
        inboundFlow.fold(0, (sum, item) => sum + item.toInt());
    weeklyOutbound.value =
        outboundFlow.fold(0, (sum, item) => sum + item.toInt());
  }

  void onCategorySelected(String categoryName) {
    final match = categories.where((c) => c.name == categoryName);

    if (match.isNotEmpty) {
      Get.toNamed(AppRoutes.categoryDetail, arguments: match.first);
    } else {
      TSnackbarsWidget.error(
          title: TTexts.errorUnknownTitle.tr,
          message: TTexts.errorUnknownMessage.tr);
    }
  }

  void goToAddCategory() {
    Get.toNamed(AppRoutes.categoryForm)?.then((_) {
      fetchDashboardData(isRefresh: true);
    });
  }
}
