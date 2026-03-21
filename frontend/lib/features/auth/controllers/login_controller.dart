import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/t_full_screen_loader.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      final res = await authProvider.login(
          email: request.email, password: request.password);

      final user = res.user;

      if (user == null) {
        Get.snackbar("Error", "Login thất bại");
        return;
      }

      if (user.emailConfirmedAt == null) {
        await Supabase.instance.client.auth.signOut();

        Get.snackbar(
          "Warning",
          "Vui lòng xác thực email trước khi đăng nhập",
        );
        return;
      }

//Tạo user profile cho lần đăng nhập lần đầu
      await UserProfileProvider().createUserProfile();

      await Get.find<StoreService>().saveUserLogin(
        email,
        password,
        rememberMe.value,
      );

      // 2. TẮT LOADING KHI THÀNH CÔNG (Trước khi chuyển trang)
      TFullScreenLoader.stopLoading();

      TSnackbars.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': email.split('@')[0],
        }),
      );

      Get.offAllNamed(AppRoutes.main);
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

  Future<void> loginWithGoogle() async {
    try {
      TFullScreenLoader.openLoadingDialog(TTexts.loggingIn.tr);

      // 1. Mở popup Google và lấy account
      final account = await authProvider.signInWithGoogle();

      if (account == null) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // 2. LẤY ID TOKEN ĐỂ SAU NÀY GỬI LÊN SERVER
      final auth = account.authentication;
      final String? idToken = auth.idToken;

      debugPrint("=== THÔNG TIN GOOGLE TRẢ VỀ ===");
      debugPrint("Email: ${account.email}");
      debugPrint("Name: ${account.displayName}");
      debugPrint("ID Token: $idToken");
      debugPrint("===============================");

      // 3. LƯU VÀO KÉT SẮT (REMEMBER ME) ĐỂ APP GHI NHỚ
      await Get.find<StoreService>().saveUserLogin(
        account.email,
        "google_dummy_password",
        true,
      );

      TFullScreenLoader.stopLoading();

      // 4. HIỆN THÔNG BÁO THÀNH CÔNG
      TSnackbars.success(
        title: TTexts.loginSuccessTitle.tr,
        message: TTexts.loginSuccessMessage.trParams({
          'name': account.displayName ?? account.email,
        }),
      );

      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      debugPrint('❌ Google Auth Error: $e');

      // 5. BÁO LỖI
      TSnackbars.error(
        title: TTexts.loginFailedTitle.tr,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
