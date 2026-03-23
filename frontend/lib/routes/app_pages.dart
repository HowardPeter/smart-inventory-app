import 'package:frontend/features/auth/bindings/forgot_password_binding.dart';
import 'package:frontend/features/auth/bindings/login_binding.dart';
import 'package:frontend/features/auth/bindings/register_binding.dart';
import 'package:frontend/features/auth/bindings/verify_email_binding.dart';
import 'package:frontend/features/auth/views/forgot_password_view.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/auth/views/register_view.dart';
import 'package:frontend/features/auth/views/verify_email_view.dart';
import 'package:frontend/features/home/views/home_view.dart';
import 'package:frontend/features/navigation/bindings/navigation_binding.dart';
import 'package:frontend/features/navigation/views/navigation_view.dart';
import 'package:frontend/features/onboarding/bindings/onboarding_binding.dart';
import 'package:frontend/features/profile/views/profile_view.dart';
import 'package:frontend/features/workspace/bindings/create_store_binding.dart';
import 'package:frontend/features/workspace/bindings/join_store_binding.dart';
import 'package:frontend/features/workspace/bindings/store_selection_binding.dart';
import 'package:frontend/features/workspace/views/create_store_view.dart';
import 'package:frontend/features/workspace/views/join_store_view.dart';
import 'package:frontend/features/workspace/views/store_selection_view.dart';
import 'package:frontend/features/workspace/views/workspace_ready_view.dart';
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
    // -- Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // -- On boarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Login
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Register
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Forgot password
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Verify email
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
      binding: VerfiEmailBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Store Selection
    GetPage(
      name: AppRoutes.storeSelection,
      page: () => const StoreSelectionView(),
      binding: StoreSelectionBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Create Store
    GetPage(
      name: AppRoutes.createStore,
      page: () => const CreateStoreView(),
      binding: CreateStoreBinding(),
      transition: Transition.cupertino,
    ),

    // -- Workspace Ready
    GetPage(
      name: AppRoutes.workspaceReady,
      page: () => const WorkspaceReadyView(),
      transition: Transition.cupertino,
    ),

    // -- Join Store
    GetPage(
      name: AppRoutes.joinStore,
      page: () => const JoinStoreView(),
      binding: JoinStoreBinding(),
      transition: Transition.rightToLeft,
    ),

    // -- Main (Navigation)
    GetPage(
      name: AppRoutes.main,
      page: () => const NavigationView(),
      binding: NavigationBinding(),
    ),

    // -- Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),

    // -- Profile
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
  ];
}
