import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final _storage = GetStorage(); // Khởi tạo Storage

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  /// Hàm dùng chung để đánh dấu đã xem xong Onboarding và vào Login
  void _completeOnboarding() {
    _storage.write('IS_FIRST_TIME', false);
    Get.offAllNamed(AppRoutes.login);
  }

  void onNextPressed() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(); // Trang cuối thì hoàn thành
    }
  }

  void onSkipPressed() {
    _completeOnboarding(); // Bấm skip thì hoàn thành luôn
  }
}
