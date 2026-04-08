import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_item_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentItemReasonChipsWidget
    extends GetView<StockAdjustmentItemController> {
  const StockAdjustmentItemReasonChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          child: Text(TTexts.mismatchedReasonLabel.tr,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42, // Chiều cao y hệt InsightCategoryChip
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            itemCount: controller.reasonOptions.length,
            itemBuilder: (context, index) {
              final reasonKey = controller.reasonOptions[index];

              return GestureDetector(
                onTap: () => controller.selectReason(reasonKey),
                child: Obx(() {
                  final isSelected =
                      controller.tempSelectedReason.value == reasonKey;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: AppSizes.p12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryText
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radius24),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryText
                            : AppColors.softGrey.withOpacity(0.2),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppColors.primaryText.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      reasonKey.tr,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.subText,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
