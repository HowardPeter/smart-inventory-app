import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';

class ProfileStoreCardWidget extends StatelessWidget {
  const ProfileStoreCardWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Iconsax.shop_copy, color: AppColors.primary, size: 26),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.goToEditStoreProfile();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.storeName.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primaryText,
                      ),
                    )),
                    //dòng chữ nhỏ mô tả bên dưới
                    // Text(
                    //   "Quản lý cửa hàng",
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: AppColors.primaryText.withOpacity(0.6),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                controller.goToStoreSelect();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.gradientOrangeStart,
                      AppColors.gradientOrangeEnd
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TTexts.profileBtnSwitchStore.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Iconsax.arrow_right_3_copy,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
