import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/profile_change_password_controller.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ChangePasswordButtonWidget
    extends GetView<ProfileChangePasswordController> {
  const ChangePasswordButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileChangePasswordController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.handleChangePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius16),
            ),
          ),
          child: const Text(
            "Change Password",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
