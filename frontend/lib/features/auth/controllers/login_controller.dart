import 'package:flutter/material.dart';
import 'package:frontend/core/utils/t_full_screen_loader.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/widgets/t_snackbars_widget.dart';
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

    // 1. GỌI LOADING GIAO DIỆN MỚI
    isLoading.value = true;
    TFullScreenLoader.openLoadingDialog(TTexts.loggingIn.tr);

    try {
      final request = LoginRequestModel(email: email, password: password);
      final userProfile = await authProvider.loginWithEmail(request);

      await Get.find<AuthService>().saveUserLogin(
        email,
        password,
        rememberMe.value,
      );

      // 2. TẮT LOADING KHI THÀNH CÔNG (Trước khi chuyển trang)
      TFullScreenLoader.stopLoading();

      TSnackbars.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': userProfile.fullName,
        }),
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      // 3. TẮT LOADING KHI BỊ LỖI
      TFullScreenLoader.stopLoading();

      TSnackbars.error(
        title: TTexts.loginFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
