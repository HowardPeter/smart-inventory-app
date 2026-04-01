import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/user_service.dart';
// import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class ProfileEditController extends GetxController {
  final UserService userService = Get.find<UserService>();

  // controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;

  // ===== INIT DATA =====
  @override
  void onInit() {
    super.onInit();

    final user = userService.currentUser.value;

    if (user != null) {
      nameController.text = user.fullName ?? '';
      emailController.text = user.email ?? '';
    }
  }

  Future<void> handleUpdateProfile() async {
    await updateProfile();
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.loginErrorEmptyFieldsTitle.tr,
        message: TTexts.loginErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    isLoading.value = true;
    FullScreenLoaderUtils.openLoadingDialog(TTexts.editLoading.tr);

    try {
      // --test
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = userService.currentUser.value;

      if (currentUser != null) {
        userService.currentUser.value = currentUser.copyWith(
          fullName: name,
          email: email,
        );
      }

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
        title: TTexts.loginSuccessTitle.tr,
        message: "Profile updated successfully",
      );

      Get.back();
    }

    // TIMEOUT
    on TimeoutException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    }

    // NETWORK
    on SocketException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    }

    // OTHER
    catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // CLEAN
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
