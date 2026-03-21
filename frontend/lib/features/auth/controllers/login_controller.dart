import 'package:flutter/material.dart';
import 'package:frontend/core/utils/t_full_screen_loader.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/auth/providers/user_profile_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/login_request_model.dart';

class LoginController extends GetxController {
  final AuthProvider authProvider;
  LoginController({required this.authProvider});

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
    TFullScreenLoader.openLoadingDialog(TTexts.loggingIn.tr);

    try {
      final request = LoginRequestModel(email: email, password: password);
      final res = await authProvider.login(
          email: request.email, password: request.password);

      final user = res.user;

      if (user == null) {
        Get.snackbar("Error", "Login thất bại");
        return;
      }

      if (user.emailConfirmedAt == null) {
        await Supabase.instance.client.auth.signOut();
        Get.snackbar("Warning", "Vui lòng xác thực email trước khi đăng nhập");
        return;
      }

      await UserProfileProvider().createUserProfile();

      await Get.find<AuthService>().saveUserLogin(
        email,
        password,
        rememberMe.value,
      );

      TFullScreenLoader.stopLoading();

      TSnackbars.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': email.split('@')[0],
        }),
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TSnackbars.error(
        title: TTexts.loginFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      TFullScreenLoader.openLoadingDialog(TTexts.loggingIn.tr);

      // 1. Nhận về AuthResponse từ Supabase
      final response = await authProvider.signInWithGoogle();

      if (response == null || response.user == null) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final user = response.user!;

      // Thông tin Full Name từ Google sẽ được lưu trong userMetadata
      final String displayName = user.userMetadata?['full_name'] ??
          user.email?.split('@')[0] ??
          'User';

      // 2. Tùy chọn: Gọi tạo UserProfile giống như login thường
      // Điều này đảm bảo user dùng Google lần đầu vẫn có dữ liệu profile
      await UserProfileProvider().createUserProfile(fullName: displayName);

      debugPrint("=== THÔNG TIN SUPABASE TRẢ VỀ TỪ GOOGLE ===");
      debugPrint("Email: ${user.email}");
      debugPrint("Name: $displayName");
      debugPrint("=========================================");

      // 3. LƯU VÀO KÉT SẮT (REMEMBER ME) ĐỂ APP GHI NHỚ
      await Get.find<AuthService>().saveUserLogin(
        user.email ?? "",
        "google_dummy_password",
        true,
      );

      TFullScreenLoader.stopLoading();

      // 4. HIỆN THÔNG BÁO THÀNH CÔNG
      TSnackbars.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': displayName,
        }),
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      debugPrint('❌ Google Auth Error: $e');

      TSnackbars.error(
        title: TTexts.loginFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
