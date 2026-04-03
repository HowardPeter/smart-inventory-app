import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/url_helper.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/features/search/models/search_product_model.dart';
import 'package:frontend/features/search/providers/search_provider.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

enum SearchTarget { global, inventory, transactions, users }

class TSearchController extends GetxController with TErrorHandler {
  final SearchProvider _provider = SearchProvider();
  final storage = GetStorage();

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final scrollController = ScrollController();

  final RxString currentSearchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  // Biến lưu trữ từ khóa gợi ý "Did you mean"
  final RxString suggestion = ''.obs;

  String dynamicHint = TTexts.searchEverything.tr;

  final RxList<InventoryInsightDisplayModel> searchResults =
      <InventoryInsightDisplayModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;

  int _currentPage = 1;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    dynamicHint = args['hint'] ?? TTexts.searchEverything.tr;

    _loadRecentSearches();

    try {
      final storeService = Get.find<StoreService>();
      final userService = Get.find<UserService>();

      ever(storeService.currentStoreId, (_) => _loadRecentSearches());

      ever(userService.currentUser, (_) => _loadRecentSearches());
    } catch (e) {
      debugPrint("Services not initialized yet.");
    }

    scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => focusNode.requestFocus());
  }

  String get _currentStorageKey {
    try {
      final storeService = Get.find<StoreService>();
      final userService = Get.find<UserService>();

      final storeId = storeService.currentStoreId.value;

      final userId = userService.currentUser.value?.userId ?? 'guest';

      if (storeId.isEmpty) {
        return 'RECENT_SEARCHES_USER_${userId}_DEFAULT';
      }

      return 'RECENT_SEARCHES_USER_${userId}_STORE_$storeId';
    } catch (e) {
      return 'RECENT_SEARCHES_DEFAULT';
    }
  }

  InventoryInsightDisplayModel _mapToDisplayModel(SearchProductModel s) {
    return InventoryInsightDisplayModel(
      inventory: InventoryModel(
        inventoryId: '',
        quantity: s.quantity,
        reorderThreshold: s.reorderThreshold,
        lastCount: 0,
        updatedAt: DateTime.now(),
        productPackageId: s.productPackageId ?? '',
        activeStatus: 'active',
        productPackage: ProductPackageModel(
          productPackageId: s.productPackageId ?? '',
          displayName: s.displayName ?? s.productName,
          importPrice: s.importPrice ?? 0,
          sellingPrice: s.sellingPrice ?? 0,
          unitId: s.unitId ?? '',
          productId: s.productId,
          activeStatus: 'active',
          barcodeValue: s.barcodeValue,
        ),
      ),
      product: ProductModel(
        productId: s.productId,
        name: s.productName,
        imageUrl: UrlHelper.normalizeImageUrl(s.imageUrl),
        brand: s.brand,
        categoryId: s.categoryId,
        storeId: '',
        activeStatus: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _executeSearch(String query) async {
    isSearching.value = true;
    _currentPage = 1;
    hasMore.value = true;
    suggestion.value = '';
    try {
      final response =
          await _provider.searchProductsByKeyword(query, page: _currentPage);
      final List<SearchProductModel> rawItems = response['items'];

      final mappedItems = rawItems
          .where((i) => i.productPackageId != null)
          .map((i) => _mapToDisplayModel(i))
          .toList();

      searchResults.assignAll(mappedItems);

      // --- LOGIC: DID YOU MEAN ---
      if (mappedItems.isEmpty && query.trim().isNotEmpty) {
        // Thuật toán "Lùi một bước": Bỏ ký tự cuối cùng của từ khóa để tìm gợi ý
        // Ví dụ: "c3" -> "c". Hoặc "pepsa" -> "peps"
        String fallbackPrefix =
            query.length > 1 ? query.substring(0, query.length - 1) : query;

        final prefixResults =
            await _provider.searchProductsByPrefix(fallbackPrefix);

        if (prefixResults.isNotEmpty) {
          // Lấy tên sản phẩm đầu tiên
          final String firstSuggestion = prefixResults.first['name'] ?? '';

          // Chỉ hiện gợi ý nếu từ khóa gợi ý thực sự khác với từ khóa đang gõ sai
          if (firstSuggestion.isNotEmpty &&
              firstSuggestion.toLowerCase() != query.toLowerCase()) {
            suggestion.value = firstSuggestion;
          }
        }
      }

      if (_currentPage >= (response['totalPages'] as int)) {
        hasMore.value = false;
      }
    } catch (e) {
      handleError(e);
    } finally {
      isSearching.value = false;
    }
  }

  void onSearchChanged(String query) {
    currentSearchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 500),
          () => _executeSearch(query.trim()));
    } else {
      searchResults.clear();
      suggestion.value = '';
    }
  }

  // --- HÀM KHI BẤM VÀO GỢI Ý ---
  void applySuggestion() {
    if (suggestion.isNotEmpty) {
      final newQuery = suggestion.value;
      textController.text = newQuery;
      // Đưa con trỏ văn bản về cuối dòng
      textController.selection =
          TextSelection.collapsed(offset: newQuery.length);
      onSearchChanged(newQuery);
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoadingMore.value ||
        !hasMore.value ||
        currentSearchQuery.value.trim().isEmpty) {
      return;
    }

    isLoadingMore.value = true;
    _currentPage++;
    try {
      final response = await _provider.searchProductsByKeyword(
          currentSearchQuery.value.trim(),
          page: _currentPage);
      final List<SearchProductModel> rawItems = response['items'];
      final mappedNewItems = rawItems
          .where((i) => i.productPackageId != null)
          .map((i) => _mapToDisplayModel(i))
          .toList();

      if (mappedNewItems.isEmpty &&
          _currentPage >= (response['totalPages'] as int)) {
        hasMore.value = false;
      } else {
        searchResults.addAll(mappedNewItems);
      }
    } catch (e) {
      _currentPage--;
      handleError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void handleItemTap(InventoryInsightDisplayModel item) {
    saveRecentSearch(currentSearchQuery.value);
    final target =
        Get.arguments?['target'] as SearchTarget? ?? SearchTarget.inventory;

    if (target == SearchTarget.transactions) {
      Get.toNamed(
        AppRoutes.transactionItemAdd,
        arguments: item,
      );
    } else {
      Get.toNamed(
        AppRoutes.inventoryDetail,
        arguments:
            item.product?.productId ?? item.inventory.productPackage?.productId,
      );
    }
  }

  void _loadRecentSearches() {
    final List<dynamic>? savedList = storage.read(_currentStorageKey);
    if (savedList != null) {
      recentSearches.assignAll(savedList.cast<String>());
    } else {
      recentSearches.clear();
    }
  }

  void saveRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    final q = query.trim();
    recentSearches.remove(q);
    recentSearches.insert(0, q);
    if (recentSearches.length > 10) recentSearches.removeLast();

    storage.write(_currentStorageKey, recentSearches.toList());
  }

  void clearRecentSearches() {
    recentSearches.clear();
    storage.remove(_currentStorageKey);
  }

  void clearSearch() {
    textController.clear();
    currentSearchQuery.value = '';
    searchResults.clear();
    suggestion.value = '';
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
