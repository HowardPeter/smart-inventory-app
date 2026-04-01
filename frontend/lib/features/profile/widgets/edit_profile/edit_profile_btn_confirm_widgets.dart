import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/profile_edit_profile_controller.dart';
import 'package:get/get.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class EditProfileSaveButtonWidget extends StatelessWidget {
  const EditProfileSaveButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileEditController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            controller.handleUpdateProfile();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gradientOrangeStart,
            foregroundColor: AppColors.whiteText,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius16),
            ),
          ),
          child: Text(
            TTexts.changePasswordBtnConfirm.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
