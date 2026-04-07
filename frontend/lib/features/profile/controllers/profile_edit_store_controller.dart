import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';

class ProfileEditStoreController extends GetxController {
  //controller
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;

// HANDLE CHANGE PASSWORD
  Future<void> handleChangePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    // ===== VALIDATE =====
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.loginErrorEmptyFieldsTitle.tr,
        message: TTexts.loginErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    if (newPass != confirmPass) {
      TSnackbarsWidget.error(
        title: "Error",
        message: "Passwords do not match",
      );
      return;
    }

    if (newPass.length < 6) {
      TSnackbarsWidget.warning(
        title: "Weak Password",
        message: "Password must be at least 6 characters",
      );
      return;
    }

    isLoading.value = true;
    FullScreenLoaderUtils.openLoadingDialog("Updating password...");

    try {
      // ===== MOCK API =====
      await Future.delayed(const Duration(seconds: 1));

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: "Success",
        message: "Password updated successfully",
      );

      Get.back();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: "Error",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
