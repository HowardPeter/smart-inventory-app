import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
// IMPORT XỬ LÝ LỖI
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';

class InventoryInsightController extends GetxController with TErrorHandler {
  final InventoryController _parentCtrl = Get.find<InventoryController>();

  final RxString activeFilter = TTexts.tabAll.obs;
  final RxString activeCategory = TTexts.allItems.obs;

  // Lấy trạng thái loading từ Controller tổng
  RxBool get isLoading => _parentCtrl.isLoading;

  List<CategoryModel> get categories => _parentCtrl.categories;

  // HÀM REFRESH KHI KÉO XUỐNG
  Future<void> refreshData() async {
    try {
      await _parentCtrl.fetchDashboardData();
    } catch (e) {
      handleError(e); // Bật Snackbar báo lỗi ngay lập tức
    }
  }

  List<InventoryModel> get filteredInventories {
    final all = List<InventoryModel>.from(_parentCtrl.inventories);
    List<InventoryModel> filteredList = all;

    if (activeFilter.value == TTexts.tabHealthy) {
      filteredList =
          filteredList.where((i) => i.quantity > i.reorderThreshold).toList();
    } else if (activeFilter.value == TTexts.tabLowStock) {
      filteredList = filteredList
          .where((i) => i.quantity > 0 && i.quantity <= i.reorderThreshold)
          .toList();
    } else if (activeFilter.value == TTexts.tabOutStock) {
      filteredList = filteredList.where((i) => i.quantity == 0).toList();
    }

    if (activeCategory.value != TTexts.allItems) {
      filteredList = filteredList.where((inv) {
        final product = _parentCtrl.products.firstWhereOrNull(
            (p) => p.productId == inv.productPackage?.productId);
        final category = categories
            .firstWhereOrNull((c) => c.categoryId == product?.categoryId);
        return category?.name == activeCategory.value;
      }).toList();
    }

    filteredList.sort((a, b) {
      if (a.quantity == 0 && b.quantity > 0) return -1;
      if (b.quantity == 0 && a.quantity > 0) return 1;
      double ratioA =
          a.reorderThreshold > 0 ? a.quantity / a.reorderThreshold : 999;
      double ratioB =
          b.reorderThreshold > 0 ? b.quantity / b.reorderThreshold : 999;
      return ratioA.compareTo(ratioB);
    });

    return filteredList;
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
