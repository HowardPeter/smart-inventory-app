import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HomeInventoryHeaderWidget extends StatelessWidget {
  const HomeInventoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.homeInventoryOverview.tr,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: 4),
        Text(
          '2,450 ${TTexts.homeTotalItems.tr}',
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: AppColors.primary,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
