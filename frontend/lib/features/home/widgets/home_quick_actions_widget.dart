import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

class HomeQuickActionsWidget extends StatelessWidget {
  const HomeQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề sử dụng TTexts
          Text(
            TTexts.homeQuickActions.tr,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSizes.p12),

          // Danh sách cuộn ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.qr_code_scanner_rounded,
                  label: TTexts.homeScanBarcode.tr,
                  color: Colors.blue,
                  bgColor: AppColors.toastInfoBg,
                  onTap: () {},
                ),
                const SizedBox(width: AppSizes.p12),
                _buildActionChip(
                  icon: Icons.add_box_rounded,
                  label: TTexts.homeAddProduct.tr,
                  color: AppColors.primary,
                  bgColor: AppColors.toastWarningBg,
                  onTap: () {},
                ),
                const SizedBox(width: AppSizes.p12),
                _buildActionChip(
                  icon: Icons.bar_chart_rounded,
                  label: TTexts.homeViewReports.tr,
                  color: Colors.purple,
                  bgColor: const Color(0xFFF3E8FF),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius24),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppSizes.iconMd),
            const SizedBox(width: AppSizes.p8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
