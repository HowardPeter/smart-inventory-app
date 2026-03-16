import 'package:flutter/material.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/widgets/t_snackbars.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/routes/app_routes.dart';
import '../models/login_request_model.dart';

class LoginController extends GetxController {
  // Nhận Provider từ Binding truyền vào
  final AuthProvider authProvider;
  LoginController({required this.authProvider});

  // UI Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      TSnackbars.warning(
        title: TTexts.loginErrorEmptyFieldsTitle.tr,
        message: TTexts.loginErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    isLoading.value = true;
    _showLoadingOverlay();

    try {
      final request = LoginRequestModel(email: email, password: password);
      final userProfile = await authProvider.loginWithEmail(request);

      // 1. GỌI BÁC BẢO VỆ ĐỂ LƯU TRẠNG THÁI VÀ DỮ LIỆU
      await Get.find<AuthService>().saveUserLogin(
        email,
        password,
        rememberMe.value,
      );

      Get.back(); // Tắt Loading

      TSnackbars.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': userProfile.fullName,
        }),
      );

      // 2. ĐÁ SANG TRANG HOME
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.back(); // Tắt Loading
      TSnackbars.error(
        title: TTexts.loginFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
        actionText: TTexts.tryAgain.tr,
        onActionPressed: () {
          Get.back();
          passwordController.clear();
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showLoadingOverlay() {
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      barrierDismissible: false,
    );
  }
}
