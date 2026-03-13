import 'package:frontend/features/onboarding/bindings/onboarding_bindings.dart';
import 'package:frontend/features/onboarding/views/onboarding_view.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.onboarding;

  static final routes = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
