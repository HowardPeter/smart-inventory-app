import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_colors.dart';

/// Widget hiển thị tiêu đề Onboarding với chữ 'S' được cách điệu
class OnboardingTitleWidget extends StatelessWidget {
  const OnboardingTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 42,
          color: AppColors.primaryText,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: 'Empower\n',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: 'Your\n',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: 'S',
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'SuezOne',
              fontSize: 54,
            ),
          ),
          TextSpan(
            text: 'torage\n',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: 'Management',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
