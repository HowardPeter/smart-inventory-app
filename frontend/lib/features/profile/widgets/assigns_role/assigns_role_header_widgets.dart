import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';

class AssignsRoleHeaderWidget extends StatelessWidget {
  const AssignsRoleHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.assignsRoleTitle.tr,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          TTexts.assignsRoleSubtitle.tr,
          style: const TextStyle(
            color: AppColors.subText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
