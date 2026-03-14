import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // 1. Final variables (Controllers & Dependencies)
  final PageController pageController = PageController();

  // 2. State variables (Reactive)
  final RxInt currentPage = 0.obs;

  // 3. Lifecycle methods
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // 4. Public methods (Business Logic)

  /// Cập nhật state trang hiện tại khi người dùng vuốt màn hình
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  /// Xử lý chuyển trang tiếp theo hoặc hoàn thành Onboarding
  void onNextPressed() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut, // Luôn có dấu phẩy đuôi ở thuộc tính cuối
      );
    } else {
      // TODO: Mở khóa code chuyển sang màn hình Login khi đã setup Route
      // Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Xử lý bỏ qua Onboarding, tiến thẳng vào app
  void onSkipPressed() {
    // TODO: Mở khóa code chuyển thẳng sang màn hình Login
    // Get.offAllNamed(AppRoutes.login);
  }
}
