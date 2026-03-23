import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import '../../controllers/onboarding_controller.dart';
import '../../layouts/onboarding_page_one_layout.dart';
import '../../layouts/onboarding_standard_layout.dart';
import '../../widgets/onboarding_progress_widget.dart';

/// Giao diện Onboarding dành riêng cho nền tảng Mobile
class OnboardingMobileView extends GetView<OnboardingController> {
  const OnboardingMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Khung chứa danh sách các trang slide
        PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: [
            const OnboardingPageOneLayout(),
            OnboardingStandardLayout(
              image: TImages.onboardingImages.onboardingContent2,
              title: TTexts.onboardingTitle2.tr,
              subtitle: TTexts.onboardingSubtitle2.tr,
              progress: 0.66,
              startingAngle: 120.0,
              onNext: controller.onNextPressed,
              onSkip: controller.onSkipPressed,
            ),
            OnboardingStandardLayout(
              image: TImages.onboardingImages.onboardingContent3,
              title: TTexts.onboardingTitle3.tr,
              subtitle: TTexts.onboardingSubtitle3.tr,
              progress: 1.0,
              startingAngle: 240.0,
              nextIcon: Icons.check_rounded,
              onNext: controller.onNextPressed,
              onSkip: controller.onSkipPressed,
            ),
          ],
        ),

        // 2. Thanh tiến trình (Dots Indicator) cố định góc trên
        const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: AppSizes.p16, right: AppSizes.p24),
            child: Align(
              alignment: Alignment.topRight,
              child: OnboardingProgressWidget(),
            ),
          ),
        ),
      ],
    );
  }
}
