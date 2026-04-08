import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class ProfileEditController extends GetxController {
  final UserService userService = Get.find<UserService>();

  // text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;

  // ===== INIT DATA =====
  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
  }

  void _initializeUserData() {
    final user = userService.currentUser.value;
    if (user != null) {
      nameController.text = user.fullName;
      emailController.text = user.email;
    }
  }

  Future<void> handleUpdateProfile() async {
    await updateProfile();
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    // 1. Validate form
    if (name.isEmpty || email.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.loginErrorEmptyFieldsTitle.tr,
        message: TTexts.loginErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    // 2. Start Loading
    isLoading.value = true;
    FullScreenLoaderUtils.openLoadingDialog(TTexts.editLoading.tr);

    try {
      // Giả lập gọi API (thay bằng ProfileProvider)
      //todo: Thay bằng ProfileProvider để gọi API cập nhật profile
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = userService.currentUser.value;

      if (currentUser != null) {
        userService.currentUser.value = currentUser.copyWith(
          fullName: name,
          email: email,
        );
      }

      // 3. Success
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr, 
        message: TTexts.profileUpdateSuccess.tr,
      );

      Get.back(); // Quay lại trang Profile
    }

    // 4. Error Handling
    on TimeoutException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } on SocketException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // CLEANUP
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
