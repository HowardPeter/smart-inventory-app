import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/utils/t_full_screen_loader.dart';
import 'package:frontend/core/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/constants/text_strings.dart';
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
  final RxInt passwordStrength = 0.obs;

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

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength.value = 0;
    } else if (password.length < 6) {
      passwordStrength.value = 1;
    } else if (password.length < 10) {
      passwordStrength.value = 2;
    } else if (!password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[A-Z]'))) {
      passwordStrength.value = 3;
    } else {
      passwordStrength.value = 4;
    }
  }

  // --- HÀM XỬ LÝ LOGIC API ---

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      TSnackbars.warning(
        title: TTexts.registerErrorEmptyFieldsTitle.tr,
        message: TTexts.registerErrorEmptyFieldsMessage.tr,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      TSnackbars.error(
        title: TTexts.loginErrorInvalidEmailTitle.tr,
        message: TTexts.loginErrorInvalidEmailMessage.tr,
      );
      return;
    }

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

      final response = await authProvider.register(
        email: email,
        password: password,
      );

      TFullScreenLoader.stopLoading();
      if (response.user != null) {
        TSnackbars.success(
          title: TTexts.registerSuccessTitle.tr,
          message: TTexts.registerSuccessMessage.tr,
        );
        Get.toNamed(AppRoutes.verifyEmail,
            arguments: emailController.text.trim());
      }
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

  /// Đăng ký/Đăng nhập bằng Google
  Future<void> registerWithGoogle() async {
    try {
      TFullScreenLoader.openLoadingDialog(TTexts.loggingIn.tr);

      // Nhận về AuthResponse thay vì GoogleSignInAccount
      final response = await authProvider.signInWithGoogle();

      if (response == null || response.user == null) {
        TFullScreenLoader.stopLoading();
        // Bỏ qua cảnh báo tắt popup để tránh spam UI, hoặc bật lại nếu bạn muốn
        return;
      }

      final user = response.user!;

      debugPrint("=== GOOGLE REGISTER SUCCESS ===");
      debugPrint("Email: ${user.email}");
      debugPrint("ID: ${user.id}");

      TFullScreenLoader.stopLoading();

      if (response.user != null) {
        // THÊM ĐOẠN NÀY: Kiểm tra nếu identities rỗng nghĩa là email đã tồn tại
        if (response.user!.identities != null &&
            response.user!.identities!.isEmpty) {
          TSnackbars.error(
            title: TTexts.registerFailedTitle.tr,
            message: "Email này đã được đăng ký. Vui lòng đăng nhập!",
          );
          return;
        }

        // Hiện thông báo thành công và chuyển trang như cũ
        TSnackbars.success(
          title: "Đăng ký thành công!",
          message: "Vui lòng chọn đăng nhập lại bằng tài khoản google.",
        );
        Get.toNamed(
          AppRoutes.login,
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TSnackbars.error(
        title: TTexts.registerFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
