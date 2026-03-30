import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeDailySummaryWidget extends GetView<HomeController> {
  const HomeDailySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // THẺ TỔNG NHẬP (STOCK IN)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.stockIn.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stockIn.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.stockIn.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Iconsax.box_add_copy,
                          color: AppColors.stockIn, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(TTexts.homeStockIn.tr,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.stockIn,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      "+${controller.stockInToday}",
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stockIn),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.p16),

        // THẺ TỔNG XUẤT (STOCK OUT)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.stockOut.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stockOut.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.stockOut.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Iconsax.box_copy,
                          color: AppColors.stockOut, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(TTexts.homeStockOut.tr,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.stockOut,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      "-${controller.stockOutToday}",
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stockOut),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
