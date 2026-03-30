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
      // 1. XÓA ĐIỀU KIỆN `if (!isRefresh)` -> SHIMMER SẼ CHẠY KHI PULL-TO-REFRESH
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

        // 2. CHUẨN HOÁ toLowerCase() ĐỂ CHỐNG LỖI LỆCH HOA/THƯỜNG ('Active' vs 'active')
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

  // CẬP NHẬT HÀM GHI
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
      // Trích xuất ID user (Tùy thuộc vào model UserProfileModel của bạn dùng biến gì, ví dụ id hoặc userId)
      final userId = userService.currentUser.value?.userId ?? 'unknown_user';

      if (storeId.isEmpty) return 'custom_category_order_default';

      // Ghép lại thành 1 key duy nhất không đụng hàng: Ví dụ: custom_category_order_storeA_userB
      return 'custom_category_order_${storeId}_$userId';
    } catch (e) {
      // Fallback an toàn nếu chưa load được service
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
      // Tính tổng giá trị kho
      if (inv.productPackage != null) {
        tempValue += (inv.quantity * inv.productPackage!.importPrice);
      }

      // Đếm sức khỏe tồn kho
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
      // 1. Đếm số lượng Product cho từng Category
      int pCount = products.where((p) => p.categoryId == cat.categoryId).length;
      tempCatStats.add(CategoryStatModel(name: cat.name, count: pCount));

      // 2. Tính tổng số lượng Tồn kho (Quantity) cho từng Category để vẽ Distribution
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
    // ĐOẠN CẬP NHẬT: SẮP XẾP DANH MỤC THEO CUSTOM ORDER
    // =========================================================
    tempCatStats.sort((a, b) {
      // Tìm vị trí của Category trong mảng customOrder (nếu có)
      int indexA = customCategoryOrder.indexOf(a.name);
      int indexB = customCategoryOrder.indexOf(b.name);

      // Nếu cả 2 đều nằm trong danh sách custom -> Xếp ưu tiên theo thứ tự custom
      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);

      // Nếu A nằm trong custom, B thì không -> Ưu tiên A đứng trước
      if (indexA != -1) return -1;

      // Nếu B nằm trong custom, A thì không -> Ưu tiên B đứng trước
      if (indexB != -1) return 1;

      // Nếu cả 2 KHÔNG nằm trong custom -> XẮP XẾP THEO BẢNG CHỮ CÁI (Default)
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
    // Tìm data gốc xịn từ danh sách categories bằng tên
    final match = categories.where((c) => c.name == categoryName);

    if (match.isNotEmpty) {
      // Có data gốc -> Truyền thẳng nguyên cục CategoryModel sang trang sau
      Get.toNamed(AppRoutes.categoryDetail, arguments: match.first);
    } else {
      // Không có -> Báo lỗi, tuyệt đối không chuyển trang gây Crash
      TSnackbarsWidget.error(
          title: TTexts
              .errorUnknownTitle.tr, // Nên dùng .tr cho đa ngôn ngữ nếu có
          message: TTexts.errorUnknownMessage.tr);
    }
  }

  void goToAddCategory() {
    // LƯU Ý: Nếu trang tạo danh mục của bạn tên là AppRoutes.addCategory thì đổi lại nhé.
    // Ở đây tôi dùng tạm AppRoutes.categoryCatalog theo danh sách file của bạn.
    Get.toNamed(AppRoutes.categoryForm)?.then((_) {
      // Khi người dùng tắt trang Tạo Danh Mục quay về, lập tức fetch lại data
      fetchDashboardData(isRefresh: true);
    });
  }
}
