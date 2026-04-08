import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ProfileInfoWidget extends StatelessWidget {
  const ProfileInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Column(
      children: [
        const SizedBox(height: AppSizes.p12), //

        // Hiển thị Tên
        Obx(() => Text(
              controller.fullName.value.isEmpty
                  ? "Đang tải..."
                  : controller.fullName.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            )),

        const SizedBox(height: 4),

        // Hiển thị Email
        Obx(() => Text(
              controller.email.value,
              style: const TextStyle(
                color: AppColors.subText,
                fontSize: 14,
              ),
            )),
      ],
    );
  }
}
