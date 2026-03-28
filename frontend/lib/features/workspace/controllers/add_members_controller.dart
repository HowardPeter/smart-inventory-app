// lib/features/workspace/controllers/add_members_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';

class AddMembersController extends GetxController {
  final RxList<StoreMemberModel> members = <StoreMemberModel>[].obs;
  final RxBool isLoadingMembers = false.obs; // Biến kích hoạt Skeleton

  late final WorkspaceProvider _workspaceProvider;
  late final StoreService _storeService = Get.find<StoreService>();
  late final UserService _userService = Get.find<UserService>();

  // Trạng thái Invite Code
  final RxBool hasGeneratedCode = false.obs;
  final RxString activeInviteCode = "".obs;
  final RxString generatedTimeStr = "".obs;

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final storeId = _storeService.currentStoreId.value;
    final currentUserId =
        _userService.currentUser.value?.userId ?? 'dummy_user_id';

    if (storeId.isEmpty) return;

    try {
      isLoadingMembers.value = true;
      final loadedMembers =
          await _workspaceProvider.getStoreMembers(storeId, currentUserId);

      // SẮP XẾP: 1. You -> 2. Manager -> 3. Staff
      loadedMembers.sort((a, b) {
        if (a.isCurrentUser) return -1;
        if (b.isCurrentUser) return 1;
        if (a.role == 'manager' && b.role != 'manager') return -1;
        if (a.role != 'manager' && b.role == 'manager') return 1;
        return a.name.compareTo(b.name);
      });

      members.assignAll(loadedMembers);
    } catch (e) {
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: e.toString());
    } finally {
      isLoadingMembers.value = false;
    }
  }

  void onGenerateCodeTapped() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.generateCodeDialogTitle.tr,
        description: TTexts.generateCodeDialogMessage.tr,
        icon: const Text('📩', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirmGenerate.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onPrimaryPressed: () {
          Get.back(); // Tắt dialog
          _executeFakeCodeGeneration();
        },
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> _executeFakeCodeGeneration() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.generatingCode.tr);

      // Fake delay
      await Future.delayed(const Duration(seconds: 2));

      activeInviteCode.value = "K9M2XQ";
      final now = DateTime.now();
      generatedTimeStr.value = DateFormat('hh:mm a, MMM dd').format(now);
      hasGeneratedCode.value = true;

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr, message: "New code generated!");
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
    }
  }

  void copyCode() {
    Clipboard.setData(ClipboardData(text: activeInviteCode.value));
    TSnackbarsWidget.success(
        title: TTexts.inviteCodeCopiedTitle.tr,
        message: TTexts.inviteCodeCopiedMessage.tr);
  }
}
