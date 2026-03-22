import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/workspace/widgets/store_selection/store_selection_help_bottom_widget.dart';

class StoreSelectionController extends GetxController with TErrorHandler {
  final isLoading = false.obs;

  // Sử dụng StoreModel thật
  final stores = <StoreModel>[].obs;

  late final WorkspaceProvider _workspaceProvider;

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

  void selectStore(StoreModel store) {
    // TODO: Lưu store.storeId vào Local Storage để gắn vào Header `x-store-id`
    Get.offAllNamed(AppRoutes.main);
  }

  void goToCreateStore() {
    // Get.toNamed(AppRoutes.createStore);
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
