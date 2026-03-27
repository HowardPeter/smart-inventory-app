import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';

class InventoryInsightController extends GetxController with TErrorHandler {
  final InventoryController _parentCtrl = Get.find<InventoryController>();

  final RxString activeFilter = TTexts.tabAll.obs;
  final RxString activeCategory = TTexts.allItems.obs;

  RxBool get isLoading => _parentCtrl.isLoading;

  List<CategoryModel> get categories => _parentCtrl.categories;

  Future<void> refreshData() async {
    try {
      await _parentCtrl.fetchDashboardData();
    } catch (e) {
      handleError(e);
    }
  }

  // --- 2. CẬP NHẬT LẠI HÀM LẤY DANH SÁCH (TRẢ VỀ MODEL HIỂN THỊ) ---
  List<InventoryInsightDisplayModel> get displayList {
    final inventories = List<InventoryModel>.from(_parentCtrl.inventories);
    final products = _parentCtrl.products;

    // --- BƯỚC A: LỌC TRẠNG THÁI (Giữ nguyên logic cũ) ---
    List<InventoryModel> filteredInventories = inventories;
    if (activeFilter.value == TTexts.tabHealthy) {
      filteredInventories =
          inventories.where((i) => i.quantity > i.reorderThreshold).toList();
    } else if (activeFilter.value == TTexts.tabLowStock) {
      filteredInventories = inventories
          .where((i) => i.quantity > 0 && i.quantity <= i.reorderThreshold)
          .toList();
    } else if (activeFilter.value == TTexts.tabOutStock) {
      filteredInventories = inventories.where((i) => i.quantity == 0).toList();
    }

    // --- BƯỚC B: ÁNH XẠ ẢNH VÀ TẠO LIST MỚI ---
    List<InventoryInsightDisplayModel> mappedList =
        filteredInventories.map((inv) {
      // Tra cứu Product dựa trên productId nằm trong productPackage
      final product = products.firstWhereOrNull(
          (p) => p.productId == inv.productPackage?.productId);

      return InventoryInsightDisplayModel(inventory: inv, product: product);
    }).toList();

    // --- BƯỚC C: LỌC THEO DANH MỤC (Dựa trên list đã có Product) ---
    if (activeCategory.value != TTexts.allItems) {
      mappedList = mappedList.where((item) {
        final category = categories
            .firstWhereOrNull((c) => c.categoryId == item.product?.categoryId);
        return category?.name == activeCategory.value;
      }).toList();
    }

    // --- BƯỚC D: SẮP XẾP ---
    mappedList.sort((a, b) {
      if (a.inventory.quantity == 0 && b.inventory.quantity > 0) return -1;
      if (b.inventory.quantity == 0 && a.inventory.quantity > 0) return 1;
      return a.inventory.quantity.compareTo(b.inventory.quantity);
    });

    return mappedList;
  }

  int getCount(String tabKey) {
    if (tabKey == TTexts.tabHealthy) return _parentCtrl.healthyCount.value;
    if (tabKey == TTexts.tabLowStock) return _parentCtrl.lowCount.value;
    if (tabKey == TTexts.tabOutStock) return _parentCtrl.outCount.value;
    return _parentCtrl.inventories.length;
  }

  void toggleFilter(String filterKey) {
    if (activeFilter.value == filterKey) {
      activeFilter.value = TTexts.tabAll;
    } else {
      activeFilter.value = filterKey;
    }
  }

  void setCategory(String categoryName) {
    activeCategory.value = categoryName;
  }
}
