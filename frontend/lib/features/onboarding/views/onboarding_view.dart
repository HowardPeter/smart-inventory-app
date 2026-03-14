import 'package:flutter/material.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:get/get.dart';

import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/features/onboarding/controllers/onboarding_controller.dart';
import 'package:frontend/features/onboarding/layouts/onboarding_page_one_layout.dart';
import 'package:frontend/features/onboarding/layouts/onboarding_standard_layout.dart';
import 'package:frontend/features/onboarding/widgets/onboarding_progress_widget.dart';

/// View chính điều phối luồng giới thiệu (Onboarding) qua PageView
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Khung chứa danh sách các trang layout giới thiệu
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

          // Thanh tiến trình (indicator) nằm cố định ở góc trên
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
      ),
    );
  }
}
