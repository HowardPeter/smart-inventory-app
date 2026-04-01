import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/profile_edit_profile_controller.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class EditProfileFormWidget extends GetView<ProfileEditController> {
  const EditProfileFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        children: [
          // FULL NAME
          TTextFormFieldWidget(
            controller: controller.nameController,
            label: TTexts.editName.tr,
            hintText: TTexts.editHintName.tr,
            prefixIcon: Icons.person,
            // keyboardType: TextInputType.text,
          ),

          const SizedBox(height: AppSizes.p16),

          // EMAIL
          TTextFormFieldWidget(
            controller: controller.emailController,
            label: TTexts.editEmail.tr,
            hintText: TTexts.editHintEmail.tr,
            prefixIcon: Icons.email,
            // keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
