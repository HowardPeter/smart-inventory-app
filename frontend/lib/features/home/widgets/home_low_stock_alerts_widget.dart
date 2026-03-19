import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/t_custom_fade_overlay_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

class HomeLowStockAlertsWidget extends StatelessWidget {
  const HomeLowStockAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                        '8 ${TTexts.homeItems.tr}',
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
                _buildAlertItem(
                    name: 'iPhone 13',
                    category: 'Smartphones',
                    quantityLeft: 5),
                const SizedBox(height: AppSizes.p12),
                _buildAlertItem(
                    name: 'Samsung Galaxy S24',
                    category: 'Smartphones',
                    quantityLeft: 3),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // SỬ DỤNG WIDGET CHUNG Ở ĐÂY
          TCustomFadeOverlayWidget(
            text: TTexts.homeTapToViewAll.tr,
            onTap: () {
              // Xử lý chuyển trang
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
      {required String name,
      required String category,
      required int quantityLeft}) {
    String quantityText =
        TTexts.homeOnlyLeft.tr.replaceAll('@quantity', quantityLeft.toString());

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
            child: const Icon(Icons.image_outlined, color: AppColors.softGrey),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primaryText)),
                Text(category,
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
