import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/profile/controllers/profile_change_password_controller.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ChangePasswordFormWidget
    extends GetView<ProfileChangePasswordController> {
  const ChangePasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileChangePasswordController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        children: [
          // OLD PASSWORD
          TTextFormFieldWidget(
            controller: controller.oldPasswordController,
            label: TTexts.changePasswordOldPassword.tr,
            hintText: TTexts.changePasswordHintOldPassword.tr,
            isObscure: true,
            prefixIcon: Icons.lock,
          ),

          const SizedBox(height: AppSizes.p16),

          // NEW PASSWORD
          TTextFormFieldWidget(
            controller: controller.newPasswordController,
            label: TTexts.changePasswordNewPassword.tr,
            hintText: TTexts.changePasswordHintNewPassword.tr,
            isObscure: true,
            prefixIcon: Icons.lock_outline,
          ),

          const SizedBox(height: AppSizes.p16),

          // CONFIRM PASSWORD
          TTextFormFieldWidget(
            controller: controller.confirmPasswordController,
            label: TTexts.changePasswordConfirm.tr,
            hintText: TTexts.changePasswordHintConfirmPassword.tr,
            isObscure: true,
            prefixIcon: Icons.lock_reset,
          ),
        ],
      ),
    );
  }
}
