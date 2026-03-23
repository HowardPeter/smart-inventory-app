import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class CreateStoreAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const CreateStoreAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: AppColors.background.withOpacity(0.7),
          elevation: 0,
          leadingWidth: 120,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
          ),
          leading: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(AppSizes.radius8),
            child: Row(
              children: [
                const SizedBox(width: AppSizes.p16),
                const Icon(Iconsax.arrow_left_2_copy,
                    color: AppColors.primaryText, size: 20),
                const SizedBox(width: 4),
                Text(
                  TTexts.goBack.tr,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
