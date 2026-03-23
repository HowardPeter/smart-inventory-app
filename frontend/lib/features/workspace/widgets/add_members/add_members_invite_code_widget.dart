import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/workspace/controllers/add_members_controller.dart';

class AddMembersInviteCodeWidget extends GetView<AddMembersController> {
  const AddMembersInviteCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasGeneratedCode.value) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.p20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TTexts.activeInviteCodeTitle.tr,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.activeInviteCode.value,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                        color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: controller.copyCode,
                    icon:
                        const Icon(Iconsax.copy_copy, color: AppColors.primary),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                  "${TTexts.generatedAt.tr}${controller.generatedTimeStr.value}",
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.subText)),
              const SizedBox(height: 4),
              Text(TTexts.expiresAt.tr,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.onGenerateCodeTapped,
            icon: const Icon(Iconsax.add_square_copy, color: Colors.white),
            label: Text(
              TTexts.generateInviteCodeBtn.tr,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      }
    });
  }
}
