import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:intl/intl.dart';

class HomeInventoryHeaderWidget extends GetView<HomeController> {
  const HomeInventoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Format số có dấu phẩy (vd: 2,450)
    final numberFormat = NumberFormat('#,##0');

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
        Obx(() {
          return Text(
            '${numberFormat.format(controller.totalStockQuantity)} ${TTexts.homeTotalItems.tr}',
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          );
        }),
      ],
    );
  }
}
