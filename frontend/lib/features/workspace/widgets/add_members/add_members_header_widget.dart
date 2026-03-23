import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class AddMembersHeaderWidget extends StatelessWidget {
  const AddMembersHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.addMembersTitle.tr,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          TTexts.addMembersSubtitle.tr,
          style: const TextStyle(
              fontSize: 15, color: AppColors.subText, height: 1.5),
        ),
      ],
    );
  }
}
