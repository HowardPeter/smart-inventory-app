import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.p12),
        Text(
          TTexts.profileNameUser.tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TTexts.profileEmaiUser.tr,
          style: const TextStyle(
            color: AppColors.subText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
