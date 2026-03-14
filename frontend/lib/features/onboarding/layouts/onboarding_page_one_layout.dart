import 'package:flutter/material.dart';
import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/widgets/t_image_widget.dart';
import 'package:get/get.dart';

import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_next_button_widget.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_skip_button_widget.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_title_widget.dart';

/// Layout riêng biệt cho màn hình Onboarding đầu tiên (Trang 1)
class OnboardingPageOneLayout extends GetView<OnboardingController> {
  const OnboardingPageOneLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: Bọc ClipRect để cắt bỏ phần ảnh nền dư thừa lẹm sang trang 2
    return ClipRect(
      child: Stack(
        children: [
          // 1. Ảnh nền (Ép lún ra khỏi lề phải)
          Align(
            alignment: FractionalOffset(1.2, 1.0),
            child: TImageWidget(
              image: TImages.onboardingImages.onboardingContent1,
            ),
          ),
          // 2. Nội dung chính
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.p24,
                top: AppSizes.p32,
                bottom: AppSizes.p32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Khoảng trống nhường chỗ cho thanh Progress góc trên
                  const SizedBox(height: 56.0),
                  const OnboardingTitleWidget(),
                  const SizedBox(height: AppSizes.p32),

                  // Nút Next
                  OnboardingNextButtonWidget(
                    onTap: controller.onNextPressed,
                    progress: 0.33,
                  ),

                  const Spacer(),

                  // Nút Skip
                  OnboardingSkipButtonWidget(onTap: controller.onSkipPressed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
