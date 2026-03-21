import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

/// Widget hiển thị các chấm chỉ số trang (Dots Indicator) cho Onboarding
/// Sử dụng AnimatedContainer để tạo hiệu ứng dãn nở mượt mà khi chuyển trang
class OnboardingProgressWidget extends GetView<OnboardingController> {
  const OnboardingProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final isActive = controller.currentPage.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 24 : 8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}
