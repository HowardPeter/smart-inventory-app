import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';

class TransactionBottomSheetWidget extends StatelessWidget {
  const TransactionBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.softGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius16),
          ),
          child: const Center(
            child: Text("📦", style: TextStyle(fontSize: 36)),
          ),
        ),
        const SizedBox(height: AppSizes.p16),

        Text(
          TTexts.manageInventory.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            TTexts.manageInventoryDesc.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p24),

        // 4. Các nút thao tác (Sử dụng TPrimaryButtonWidget)
        TPrimaryButtonWidget(
          text: TTexts.inbound.tr,
          height: 56,
          customIcon: _buildLayerIcon(isPlus: true),
          fontSize: 16,
          onPressed: () {
            Get.back();
            // Điều hướng Inbound
          },
        ),
        const SizedBox(height: AppSizes.p12),

        TPrimaryButtonWidget(
          text: TTexts.outbound.tr,
          height: 56,
          customIcon: _buildLayerIcon(isMinus: true),
          fontSize: 16,
          onPressed: () {
            Get.back();
            // Điều hướng Outbound
          },
        ),
        const SizedBox(height: AppSizes.p12),

        TPrimaryButtonWidget(
          text: TTexts.stockAdjustment.tr,
          height: 56,
          icon: Iconsax.layer_copy, // Chỉ dùng icon thường
          fontSize: 16,
          onPressed: () {
            Get.back();
            // Điều hướng Stock Adjustment
          },
        ),
        const SizedBox(height: AppSizes.p16),

        // 5. Nút Exit
        TPrimaryButtonWidget(
          text: TTexts.exit.tr,
          height: 56,
          fontSize: 16,
          backgroundColor: AppColors.softGrey.withOpacity(0.15),
          textColor: AppColors.primaryText,
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  // --- HÀM TẠO ICON LAYER CÓ DẤU + / - (Giữ nguyên) ---
  Widget _buildLayerIcon({bool isPlus = false, bool isMinus = false}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            child: Icon(Iconsax.layer_copy, color: AppColors.white, size: 24),
          ),
          if (isPlus)
            Positioned(
              bottom: -2,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add,
                    color: AppColors.white, size: 14, weight: 800),
              ),
            ),
          if (isMinus)
            Positioned(
              bottom: -2,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove,
                    color: AppColors.white, size: 14, weight: 800),
              ),
            ),
        ],
      ),
    );
  }
}
