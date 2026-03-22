import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class StoreSelectionActionButtonsWidget extends StatelessWidget {
  final VoidCallback onJoinTap;
  final VoidCallback onCreateTap;

  const StoreSelectionActionButtonsWidget({
    super.key,
    required this.onJoinTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Bên trái: Need Help? Click
        InkWell(
          onTap: onJoinTap,
          borderRadius: BorderRadius.circular(AppSizes.radius8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AppSizes.p8, horizontal: AppSizes.p4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TTexts.needHelp.tr,
                  style:
                      const TextStyle(color: AppColors.subText, fontSize: 13),
                ),
                Text(
                  TTexts.joinAWorkspace.tr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSizes.p16),

        // 2. Bên phải: Nút Create (Bọc Expanded để fix lỗi OVERFLOW)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.gradientOrangeStart,
                  AppColors.gradientOrangeEnd
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radius24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onCreateTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.p16), // Bỏ padding ngang tĩnh
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius24)),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa nội dung nút
                children: [
                  const Icon(Iconsax.add_circle_copy,
                      color: AppColors.white, size: 20),
                  const SizedBox(width: AppSizes.p8),
                  Flexible(
                    // Giúp text không bị lỗi nếu màn hình quá nhỏ
                    child: Text(
                      TTexts.createYourWorkspace.tr,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis, // Chống tràn chữ
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
