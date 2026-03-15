import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/core/widgets/t_image_widget.dart';
import '../widgets/onboarding_next_button_widget.dart';
import '../widgets/onboarding_skip_button_widget.dart';

/// Layout chuẩn cho màn hình Onboarding (Ảnh có hiệu ứng Aura, Tiêu đề, Mô tả và Cụm nút bấm)
class OnboardingStandardLayout extends StatelessWidget {
  // 1. Final variables
  final String image;
  final String title;
  final String subtitle;
  final double progress;
  final double startingAngle;
  final IconData nextIcon;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  // 2. Constructor
  const OnboardingStandardLayout({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.startingAngle = 0.0,
    this.nextIcon = Icons.arrow_forward_ios_rounded,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.p32),

            // 1. Hình ảnh với hiệu ứng Hào quang (Aura)
            Expanded(
              flex: 3,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hiệu ứng Aura mờ phía sau
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 100,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Hình ảnh sản phẩm/nhân vật
                    TImageWidget(
                      image: image, // Biến image truyền từ PageView qua
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // 2. Tiêu đề
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                height: 1.3,
              ),
            ),

            const SizedBox(height: AppSizes.p16),

            // 3. Mô tả
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.subText,
                height: 1.5,
              ),
            ),

            const Spacer(),

            // 4. Cụm nút bấm điều hướng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OnboardingSkipButtonWidget(onTap: onSkip),
                OnboardingNextButtonWidget(
                  onTap: onNext,
                  progress: progress,
                  startingAngle: startingAngle,
                  icon: nextIcon,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
