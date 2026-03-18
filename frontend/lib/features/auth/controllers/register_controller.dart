import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/utils/t_full_screen_loader.dart';
import 'package:frontend/core/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
// import '../models/register_request_model.dart'; // Mở ra khi bạn tạo model này

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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- HÀM XỬ LÝ GIAO DIỆN ---
  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  /// Thuật toán kiểm tra độ mạnh mật khẩu theo thời gian thực
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

    // 2. Validate: Mật khẩu xác nhận phải khớp
    if (password != confirmPassword) {
      TSnackbars.error(
        title: TTexts.registerErrorPasswordMismatchTitle.tr,
        message: TTexts.registerErrorPasswordMismatchMessage.tr,
      );
      return;
    }

    try {
      isLoading.value = true;
      TFullScreenLoader.openLoadingDialog(TTexts.registering.tr);

      // SAU NÀY: Chỗ này sẽ gọi authProvider.registerWithEmail(request)
      // Tạm thời giả lập chờ mạng 2 giây
      await Future.delayed(const Duration(seconds: 2));

      TFullScreenLoader.stopLoading();

      // Hiện thông báo thành công
      TSnackbars.success(
        title: TTexts.registerSuccessTitle.tr,
        message: TTexts.registerSuccessMessage.tr,
      );

      // Chuyển hướng sang trang Xác thực Email (Gửi kèm email qua Arguments)
      Get.toNamed(AppRoutes.verifyEmail,
          arguments: emailController.text.trim());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TSnackbars.error(
        title: TTexts.registerFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Đăng ký/Đăng nhập bằng Google (Dùng chung logic với màn Login)
  Future<void> registerWithGoogle() async {
    try {
      TFullScreenLoader.openLoadingDialog(TTexts.loggingIn.tr);

      final account = await authProvider.signInWithGoogle();

      if (account == null) {
        TFullScreenLoader.stopLoading();
        TSnackbars.warning(
          title: TTexts.canceled,
          message: TTexts.googleSignInCanceled,
        );
        return;
      }

      final auth = account.authentication;
      final String? idToken = auth.idToken;

      debugPrint("=== GOOGLE REGISTER ===");
      debugPrint("Email: ${account.email}");
      debugPrint("Token: $idToken");

      TFullScreenLoader.stopLoading();

      TSnackbars.success(
        title: TTexts.registerSuccessTitle.tr,
        message: TTexts.registerSuccessMessage.tr,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TSnackbars.error(
        title: TTexts.registerFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
