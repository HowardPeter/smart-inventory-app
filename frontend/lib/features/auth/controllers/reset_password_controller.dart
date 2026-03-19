import 'package:flutter/material.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final AuthProvider provider;

  ResetPasswordController({required this.provider});

  final passwordController = TextEditingController();
  final isLoading = false.obs;

  Future<void> resetPassword() async {
    final password = passwordController.text;

    if (password.length < 6) {
      Get.snackbar("Error", "Password phải >= 6 ký tự");
      return;
    }

    try {
      isLoading.value = true;

      await provider.updatePassword(password);

      Get.snackbar("Success", "Đổi mật khẩu thành công");

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
