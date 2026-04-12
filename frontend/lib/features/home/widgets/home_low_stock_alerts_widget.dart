import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeLowStockAlertsWidget extends GetView<HomeController> {
  const HomeLowStockAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.lowStockItems;

      if (items.isEmpty) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TTexts.homeLowStockAlerts.tr,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.toastErrorBg,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12)),
                        child: Text(
                          '${items.length} ${TTexts.homeItems.tr}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.toastErrorGradientEnd,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),
                  ...items.take(3).map((item) {
                    final name = item.productPackage?.displayName ??
                        item.productPackage?.product?.name ??
                        'Unknown Product';

                    final barcode = item.productPackage?.barcodeValue;
                    final category =
                        item.productPackage?.product?.categoryId ?? 'Product';

                    final String displaySubtitle =
                        (barcode != null && barcode.isNotEmpty)
                            ? '${TTexts.barcodeLabel.tr}: $barcode'
                            : category;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: _buildAlertItem(
                        name: name,
                        subtitle: displaySubtitle,
                        quantityLeft: item.quantity,
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            TCustomFadeOverlayWidget(
              text: TTexts.homeTapToViewAll.tr,
              onTap: () {
                // TODO: Chuyển sang trang danh sách Alert
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAlertItem(
      {required String name,
      required String subtitle,
      required int quantityLeft}) {
    String quantityText = quantityLeft <= 0
        ? TTexts.homeOutOfStock.tr
        : TTexts.homeOnlyLeft.tr
            .replaceAll('@quantity', quantityLeft.toString());

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radius16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radius8)),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.toastErrorGradientEnd),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primaryText)),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.subText)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.toastErrorGradientEnd,
                      shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(quantityText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.toastErrorGradientEnd,
                      fontWeight: FontWeight.w500,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
