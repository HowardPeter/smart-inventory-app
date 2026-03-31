import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

enum SearchTarget { inventory, transactions, users }

class TSearchController extends GetxController with TErrorHandler {
  // Biến UI
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final RxString currentSearchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Biến Context
  late SearchTarget target;
  late String dynamicHint;

  // --- DỮ LIỆU TÌM KIẾM THẬT ---
  final RxList<InventoryModel> inventoryResults = <InventoryModel>[].obs;
  final RxList<String> recentSearches =
      <String>['Keyboard', 'Mouse', 'Coca Cola'].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    target = args['target'] ?? SearchTarget.inventory;
    dynamicHint = args['hint'] ?? 'Search...';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    currentSearchQuery.value = query;
    if (query.trim().length >= 2) {
      _executeSearch(query.trim());
    } else {
      // Xóa kết quả nếu gõ ít hơn 2 ký tự
      inventoryResults.clear();
    }
  }

  void clearSearch() {
    textController.clear();
    currentSearchQuery.value = '';
    inventoryResults.clear();
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }

  void saveRecentSearch(String query) {
    if (query.isNotEmpty && !recentSearches.contains(query)) {
      recentSearches.insert(0, query);
      if (recentSearches.length > 10) {
        recentSearches.removeLast(); // Chỉ lưu 10 cái gần nhất
      }
    }
  }

  Future<void> _executeSearch(String query) async {
    isSearching.value = true;
    try {
      await Future.delayed(const Duration(
          milliseconds:
              300)); // Debounce nhẹ giúp app không bị giật khi gõ liên tục

      final lowerQuery = query.toLowerCase();

      switch (target) {
        case SearchTarget.inventory:
          // --- LOGIC TÌM KIẾM THẬT ---
          // Lấy dữ liệu kho đã load sẵn từ trang trước để tìm (Nhanh như chớp)
          if (Get.isRegistered<InventoryController>()) {
            final invCtrl = Get.find<InventoryController>();

            final results = invCtrl.inventories.where((inv) {
              final pkgName =
                  inv.productPackage?.displayName.toLowerCase() ?? '';
              final barcode =
                  inv.productPackage?.barcodeValue?.toLowerCase() ?? '';

              return pkgName.contains(lowerQuery) ||
                  barcode.contains(lowerQuery);
            }).toList();

            inventoryResults.assignAll(results);
          }
          break;
        case SearchTarget.transactions:
          // TODO: Call API / Lọc Transactions
          break;
        case SearchTarget.users:
          // TODO: Call API / Lọc Users
          break;
      }
    } catch (e) {
      // HIỂN THỊ SNACKBAR LỖI NẾU CÓ SỰ CỐ
      handleError(e);
    } finally {
      isSearching.value = false;
    }
  }
}
