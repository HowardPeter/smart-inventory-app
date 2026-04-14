import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeAdjustmentStatsWidget extends GetView<HomeController> {
  const HomeAdjustmentStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final logs = controller.todayAdjustments;

      if (logs.isEmpty) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppSizes.p20,
                top: AppSizes.p20,
                right: AppSizes.p20,
                bottom: logs.length > 5 ? 60 : AppSizes.p20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TTexts.recentAdjustments.tr,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  ...logs.take(5).map((item) {
                    final timeStr = DateFormat('HH:mm').format(item.time);
                    final diffStr = item.difference == 0
                        ? '0'
                        : (item.isPositive
                            ? '+${item.difference}'
                            : '${item.difference}');
                    return GestureDetector(
                      onTap: () => controller.openDetails(item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.p12),
                        padding: const EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius16),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.03)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.sync_alt_rounded,
                                  size: 22, color: Colors.orange),
                            ),
                            const SizedBox(width: AppSizes.p16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryText),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: AppColors.softGrey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              diffStr,
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: item.isPositive
                                      ? AppColors.stockIn
                                      : AppColors.stockOut),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (logs.length > 5)
              TCustomFadeOverlayWidget(
                text: TTexts.homeTapToViewMoreHistory.tr,
                onTap: controller.goToAdjustmentHistory,
              ),
          ],
        ),
      );
    });
  }
}
