import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SearchTarget { inventory, transactions, users }

class TSearchController extends GetxController {
  // Biến UI
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final RxString currentSearchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Biến Context (Được truyền sang từ trang trước)
  late SearchTarget target;
  late String dynamicHint;

  @override
  void onInit() {
    super.onInit();
    // Bắt Arguments từ Route
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    target = args['target'] ?? SearchTarget.inventory;
    dynamicHint = args['hint'] ?? 'Search...';

    // Auto-focus bàn phím khi mở trang
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
    if (query.length > 2) {
      _executeSearch(query);
    }
  }

  void clearSearch() {
    textController.clear();
    currentSearchQuery.value = '';
    // Reset data
  }

  Future<void> _executeSearch(String query) async {
    isSearching.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Fake delay

      // LOGIC TÁI SỬ DỤNG Ở ĐÂY:
      switch (target) {
        case SearchTarget.inventory:
          // Gọi API tìm tồn kho
          break;
        case SearchTarget.transactions:
          // Gọi API tìm giao dịch
          break;
        case SearchTarget.users:
          // Gọi API tìm user
          break;
      }
    } finally {
      isSearching.value = false;
    }
  }
}
