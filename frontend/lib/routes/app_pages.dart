import 'package:frontend/features/auth/bindings/forgot_password_binding.dart';
import 'package:frontend/features/auth/bindings/login_binding.dart';
import 'package:frontend/features/auth/bindings/register_binding.dart';
import 'package:frontend/features/auth/bindings/verify_email_binding.dart';
import 'package:frontend/features/auth/views/forgot_password_view.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/auth/views/register_view.dart';
import 'package:frontend/features/auth/views/verify_email_view.dart';
import 'package:frontend/features/home/bindings/home_binding.dart';
import 'package:frontend/features/home/views/home_view.dart';
import 'package:frontend/features/onboarding/bindings/onboarding_binding.dart';
import 'package:get/get.dart';

import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/splash/bindings/splash_binding.dart';
import 'package:frontend/features/splash/views/splash_view.dart';
import 'package:frontend/features/onboarding/views/onboarding_view.dart';

class AppPages {
  AppPages._();

  // Đổi từ onboarding sang splash để app luôn khởi động từ màn hình loading
  static const initial = AppRoutes.splash;

  static final routes = [
    // Khai báo màn hình Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Giữ nguyên các màn hình khác
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
      binding: VerfiEmailBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(), // Tiêm vũ khí cho Home
    ),
  ];
}
