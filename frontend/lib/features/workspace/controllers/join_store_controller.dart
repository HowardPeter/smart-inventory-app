import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/routes/app_routes.dart';

class JoinStoreController extends GetxController {
  final inviteCodeController = TextEditingController();
  final isLoading = false.obs;

  late final WorkspaceProvider _workspaceProvider;
  late final _storeService = Get.find<StoreService>();

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();
  }

  Future<void> onJoinWorkspace() async {
    final code = inviteCodeController.text.trim().toUpperCase();

    if (code.isEmpty || code.length < 6) {
      TSnackbarsWidget.warning(
          title: TTexts.joinMissingCodeTitle.tr,
          message: TTexts.joinMissingCodeMessage.tr);
      return;
    }

    try {
      isLoading.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.checkingInviteCode.tr);

      // --- GỌI API THẬT ĐỂ JOIN STORE ---
      // Nếu user đã có trong store hoặc mã sai, Backend Node.js của bạn
      // sẽ quăng lỗi 400/404 và nhảy thẳng xuống khối catch (e) bên dưới.
      final joinedStore = await _workspaceProvider.joinStore(code);

      FullScreenLoaderUtils.stopLoading();

      // Hiện thông báo thành công
      TSnackbarsWidget.success(
          title: TTexts.joinSuccessTitle.tr,
          message: TTexts.joinSuccessMessage.tr);

      // Lưu ID và Tên cửa hàng vừa join được vào bộ nhớ máy
      await _storeService.saveSelectedStore(
          joinedStore.storeId, joinedStore.name);

      // Chuyển thẳng vào Home
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
