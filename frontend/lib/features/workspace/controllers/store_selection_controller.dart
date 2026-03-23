import 'package:flutter/foundation.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/workspace/widgets/store_selection/store_selection_help_bottom_widget.dart';

class StoreSelectionController extends GetxController with TErrorHandler {
  final isLoading = false.obs;

  // Sử dụng StoreModel thật
  final stores = <StoreModel>[].obs;

  late final WorkspaceProvider _workspaceProvider;
  final _storeService = Get.find<StoreService>();

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      isLoading.value = true;
      final fetchedStores = await _workspaceProvider.getMyStores();
      stores.assignAll(fetchedStores);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStores() async {
    try {
      isLoading.value = true;
      final fetchedStores = await _workspaceProvider.getMyStores();
      stores.assignAll(fetchedStores);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectStore(StoreModel store) async {
    try {
      debugPrint("==== DỮ LIỆU STORE: ${store.toJson()} ====");

      // Lấy storeId trực tiếp từ thuộc tính của StoreModel
      final String currentId = store.storeId;
      final String currentName = store.name;

      if (currentId.isEmpty) {
        debugPrint("LỖI CRITICAL: ID Cửa hàng bị rỗng!");
        Get.snackbar("Lỗi Hệ Thống", "Không tìm thấy ID của cửa hàng này.");
        return;
      }

      debugPrint("LƯU VÀO MÁY STORE_ID: $currentId");

      // Lưu vào máy và RAM
      await _storeService.saveSelectedStore(currentId, currentName);

      // Nhảy vào trang Home
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      handleError(e);
    }
  }

  void goToCreateStore() {
    Get.toNamed(AppRoutes.createStore);
  }

  void goToJoinStore() {
    // Get.toNamed(AppRoutes.joinStore);
  }

  void showHelpBottomSheet() {
    Get.bottomSheet(
      const StoreSelectionHelpBottomWidget(),
      isScrollControlled: true,
    );
  }
}
