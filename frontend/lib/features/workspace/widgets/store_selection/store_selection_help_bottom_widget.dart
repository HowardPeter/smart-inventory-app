import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class StoreSelectionHelpBottomWidget extends StatelessWidget {
  const StoreSelectionHelpBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TBottomSheetWidget(
      title: TTexts.needHelp.tr, // Lấy từ TTexts
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon minh họa nổi bật
          Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: const BoxDecoration(
              color: AppColors.toastInfoBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.info_circle_copy,
              color: AppColors.toastInfoGradientEnd,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // Nội dung dặn dò chi tiết
          Text(
            TTexts.whatIsWorkspace.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          Text(
            TTexts.workspaceDescription.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.subText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSizes.p32),

          // Nút xác nhận
          TPrimaryButtonWidget(
            text: TTexts.understood.tr,
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
