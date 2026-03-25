import 'package:flutter/material.dart';
import 'package:frontend/features/inventory/models/dashboard_stat_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import '../providers/inventory_provider.dart';

class InventoryController extends GetxController {
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

  final RxList<double> inboundFlow = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  final RxList<double> outboundFlow = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  // Tổng In/Out trong tuần
  final RxInt weeklyInbound = 0.obs;
  final RxInt weeklyOutbound = 0.obs;

  // Cảnh báo khẩn cấp
  final RxList<InventoryModel> urgentItems = <InventoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInventoryData();
    fetchFlowHistory(); // Gọi thêm hàm lấy lịch sử
  }

  Future<void> fetchInventoryData() async {
    isLoading.value = true;
    try {
      // 1. Fetch toàn bộ data song song (Tối ưu tốc độ)
      final results = await Future.wait([
        _provider.getCategories(),
        _provider.getProducts(),
        _provider.getInventories(),
      ]);

      categories.value = results[0] as List<CategoryModel>;
      products.value = results[1] as List<ProductModel>;
      inventories.value = results[2] as List<InventoryModel>;

      // 2. Tính toán Dashboard
      _calculateDashboardInsights();
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu kho: $e");
      // TODO: Thêm TSnackbarsWidget báo lỗi ở đây nếu muốn
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFlowHistory() async {
    try {
      // TODO: Thay bằng Provider gọi API lấy Transaction History 7 ngày qua
      // Ví dụ: final res = await _provider.getWeeklyFlow();

      // Hiện tại ta gán data giả lập ở TẦNG CONTROLLER, để UI hoàn toàn sạch.
      // Khi có API thật, bạn chỉ cần gán data từ API vào 2 biến này là xong.
      inboundFlow.value = [20, 40, 15, 50, 30, 10, 5];
      outboundFlow.value = [10, 25, 30, 10, 40, 5, 5];

      weeklyInbound.value = 1240; // Gán từ API
      weeklyOutbound.value = 850; // Gán từ API
    } catch (e) {
      debugPrint("Lỗi tải lịch sử luân chuyển: $e");
    }
  }

  void _calculateDashboardInsights() {
    int hCount = 0;
    int lCount = 0;
    int oCount = 0;
    double tValue = 0.0;
    List<InventoryModel> urgentList = [];

    // Lọc ra số lượng Active Products
    totalActiveProducts.value =
        products.where((p) => p.activeStatus == 'active').length;

    // Duyệt qua từng bản ghi tồn kho
    for (var inv in inventories) {
      // Tính tổng vốn (Quantity * Import Price của package đó)
      if (inv.productPackage != null) {
        tValue += (inv.quantity * inv.productPackage!.importPrice);
      }

      // Phân loại sức khỏe (Health)
      if (inv.quantity == 0) {
        oCount++; // Out of stock
        urgentList.add(inv);
      } else if (inv.quantity <= inv.reorderThreshold) {
        lCount++; // Low stock
        urgentList.add(inv);
      } else {
        hCount++; // Healthy
      }
    }

    // Cập nhật State
    healthyCount.value = hCount;
    lowCount.value = lCount;
    outCount.value = oCount;
    totalStockValue.value = tValue;

    // Sắp xếp Urgent List ưu tiên Out of stock (số lượng = 0) đưa lên đầu
    urgentList.sort((a, b) => a.quantity.compareTo(b.quantity));
    urgentItems.value = urgentList;

    // Tính % Sức khỏe = (Mã Tốt / Tổng Mã) * 100
    final int totalInventories = inventories.length;
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

    // Lọc ra Top 5 danh mục có tồn kho lớn nhất
    tempDist.sort((a, b) => b.value.compareTo(a.value));
    topDistribution.value = tempDist.take(5).map((e) {
      return DistributionModel(
          name: e.name,
          value: e.value,
          max: maxDistValue == 0 ? 1 : maxDistValue);
    }).toList();
  }
}
