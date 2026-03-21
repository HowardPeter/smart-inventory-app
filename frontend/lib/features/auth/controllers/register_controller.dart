import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase để bắt AuthException

import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class RegisterController extends GetxController {
  final AuthProvider authProvider;
  RegisterController({required this.authProvider});

  // UI Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Biến trạng thái (State)
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  final RxInt passwordStrength =
      0.obs; // 0: Trống, 1: Weak, 2: Fair, 3: Good, 4: Strong

  // --- HÀM XỬ LÝ GIAO DIỆN ---
  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength.value = 0;
    } else if (password.length < 6) {
      passwordStrength.value = 1; // Weak
    } else if (password.length < 10) {
      passwordStrength.value = 2; // Fair
    } else if (!password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[A-Z]'))) {
      passwordStrength.value = 3; // Good (thiếu số hoặc chữ hoa)
    } else {
      passwordStrength.value = 4; // Strong (Dài, có số và chữ hoa)
    }
  }

  // --- HÀM XỬ LÝ LOGIC API ---

  /// Đăng ký bằng Email & Mật khẩu
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // 1. Validate: Không được bỏ trống
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      TSnackbars.warning(
        title: TTexts.registerErrorEmptyFieldsTitle.tr,
        message: TTexts.registerErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    // 2. Validate: Kiểm tra định dạng Email
    if (!GetUtils.isEmail(email)) {
      TSnackbars.error(
        title: TTexts.loginErrorInvalidEmailTitle.tr,
        message: TTexts.loginErrorInvalidEmailMessage.tr,
      );
      return;
    }

    // 3. Validate: Mật khẩu xác nhận phải khớp
    if (password != confirmPassword) {
      TSnackbars.error(
        title: TTexts.registerErrorPasswordMismatchTitle.tr,
        message: TTexts.registerErrorPasswordMismatchMessage.tr,
      );
      return;
    }

    try {
      isLoading.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.registering.tr);

      // GỌI API KÈM TIMEOUT 15 GIÂY
      final response = await authProvider
          .register(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 15));

      FullScreenLoaderUtils.stopLoading();

      if (response.user != null) {
        // Hiện thông báo thành công
        TSnackbars.success(
          title: TTexts.registerSuccessTitle.tr,
          message: TTexts.registerSuccessMessage.tr,
        );
        // Chuyển hướng sang trang Xác thực Email (Gửi kèm email qua Arguments)
        Get.toNamed(AppRoutes.verifyEmail, arguments: email);
      }
    } on AuthException catch (e) {
      // BẮT LỖI TỪ SUPABASE (Trùng email, mật khẩu yếu...)
      FullScreenLoaderUtils.stopLoading();
      final errorMsg = e.message.toLowerCase();

      if (errorMsg.contains('already registered') ||
          errorMsg.contains('already exists')) {
        TSnackbars.error(
          title: TTexts.registerErrorUserExistsTitle.tr,
          message: TTexts.registerErrorUserExistsMessage.tr,
        );
      } else if (errorMsg.contains('weak password') ||
          errorMsg.contains('password should be')) {
        TSnackbars.error(
          title: TTexts.registerErrorWeakPasswordTitle.tr,
          message: TTexts.registerErrorWeakPasswordMessage.tr,
        );
      } else {
        TSnackbars.error(
          title: TTexts.registerFailedTitle.tr,
          message: e.message,
        );
      }
    } on TimeoutException catch (_) {
      // BẮT LỖI QUÁ HẠN THỜI GIAN
      FullScreenLoaderUtils.stopLoading();
      TSnackbars.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } on SocketException catch (_) {
      // BẮT LỖI MẤT MẠNG LÚC ĐANG GỌI API
      FullScreenLoaderUtils.stopLoading();
      TSnackbars.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      // BẮT CÁC LỖI KHÁC
      FullScreenLoaderUtils.stopLoading();
      TSnackbars.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Đăng ký/Đăng nhập bằng Google
  Future<void> registerWithGoogle() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loggingIn.tr);

      final account = await authProvider.signInWithGoogle();

      if (account == null) {
        FullScreenLoaderUtils.stopLoading();
        TSnackbars.warning(
          title: TTexts.canceled.tr,
          message: TTexts.googleSignInCanceled.tr,
        );
        return;
      }

      // final auth = account.authentication;
      // final String? idToken = auth.idToken;

      FullScreenLoaderUtils.stopLoading();

      TSnackbars.success(
        title: TTexts.registerSuccessTitle.tr,
        message: TTexts.registerSuccessMessage.tr,
      );

      Get.offAllNamed(AppRoutes.main);
    } on SocketException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbars.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbars.error(
        title: TTexts.registerFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
