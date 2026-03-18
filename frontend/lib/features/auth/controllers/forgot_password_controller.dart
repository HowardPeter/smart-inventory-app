import 'package:flutter/material.dart';
import 'package:frontend/core/utils/t_full_screen_loader.dart';
import 'package:frontend/core/widgets/t_snackbars_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/constants/text_strings.dart';

class ForgotPasswordController extends GetxController {
  final AuthProvider authProvider;

  ForgotPasswordController({required this.authProvider});

  final emailController = TextEditingController();
  var isLoading = false.obs;

  void sendResetLink() async {
    final email = emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      TSnackbars.error(
        title: TTexts.loginErrorInvalidEmailTitle.tr,
        message: TTexts.loginErrorInvalidEmailMessage.tr,
      );
      return;
    }

    // 1. BẬT LOADING CỦA NÚT BẤM (đổi chữ thành Sending...)
    isLoading.value = true;

    try {
      TFullScreenLoader.openLoadingDialog('Checking email...');

      await authProvider.sendPasswordResetEmail(email);

      // Tắt màn hình Loading xoay xoay
      TFullScreenLoader.stopLoading();

      TSnackbars.success(
        title: TTexts.emailSentTitle.tr,
        message: TTexts.emailSentMessage.trParams({'email': email}),
      );

      // 2. SỬA LỖI CHUYỂN TRANG: Dùng Get.toNamed cho biến String
      Get.toNamed(AppRoutes.verifyEmail, arguments: email);
    } catch (e) {
      // Đảm bảo tắt Loading xoay xoay nếu có lỗi
      TFullScreenLoader.stopLoading();

      TSnackbars.error(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      // 3. CHỐNG KẸT NÚT: Dù thành công hay thất bại cũng phải trả nút về bình thường
      isLoading.value = false;
    }
  }

  /// Đóng hộp thoại Loading an toàn
  static void stopLoading() {
    // Chỉ đóng khi chắc chắn có một dialog đang mở
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
