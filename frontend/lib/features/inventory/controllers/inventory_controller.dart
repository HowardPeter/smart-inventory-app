import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/models/dashboard_stat_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import '../providers/inventory_provider.dart';

class InventoryController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  // --- Dữ liệu gốc từ API ---
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;
  final RxList<CategoryStatModel> categoryStats = <CategoryStatModel>[].obs;
  final RxList<DistributionModel> topDistribution = <DistributionModel>[].obs;

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
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Chạy song song 3 API để tối ưu thời gian tải
      final results = await Future.wait([
        _provider.getCategories(),
        _provider.getProducts(),
        _provider.getInventories(),
      ]);

      categories.assignAll(results[0] as List<CategoryModel>);
      products.assignAll(results[1] as List<ProductModel>);
      inventories.assignAll(results[2] as List<InventoryModel>);

      _calculateDashboardInsights();
    } catch (e) {
      // ĐÃ SỬA: SỬ DỤNG TErrorHandler ĐỂ BẬT SNACKBAR THÔNG BÁO LỖI THAY VÌ CHỈ PRINT
      handleError(e);
    } finally {
      isLoading.value = false;
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

    categoryStats.value = tempCatStats;

    // Lọc ra Top 5 danh mục có Volume lớn nhất (giảm dần)
    tempDist.sort((a, b) => b.value.compareTo(a.value));
    topDistribution.value = tempDist.take(5).map((e) {
      return DistributionModel(
          name: e.name,
          value: e.value,
          max: maxDistValue == 0 ? 1 : maxDistValue);
    }).toList();

    // --- MOCK DATA CHO FLOW CHART ---
    // Tạm thời fix cứng data vì chưa có API Transactions
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
}
