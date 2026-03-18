import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

import 'package:frontend/core/widgets/t_image_widget.dart';
import 'package:frontend/core/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/auth/controllers/forgot_password_controller.dart';

class ForgotPasswordFormWidget extends GetView<ForgotPasswordController> {
  const ForgotPasswordFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.verifyEmailInnerTitle.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),

        Center(
          child: TImageWidget(
            image: TImages.authImages.forgotPasswordContent1,
            height: 180,
          ),
        ),
        const SizedBox(height: AppSizes.p32),

        TTextFormField(
          controller: controller.emailController,
          label: TTexts.emailLabel.tr,
          hintText: TTexts.emailHint.tr,
        ),
        const SizedBox(height: AppSizes.p24),

        // Nút Gửi Email (Nút chính)
        Obx(() => TPrimaryButton(
              text: controller.isLoading.value
                  ? 'Sending...'
                  : TTexts.forgotPasswordBtn.tr,
              onPressed:
                  controller.isLoading.value ? null : controller.sendResetLink,
            )),
        const SizedBox(height: AppSizes.p16),

        // Nút Quay Lại (Nút viền cực kỳ gọn gàng)
        TPrimaryButton(
          text: TTexts.goBack.tr,
          isOutlined: true, // Kích hoạt chế độ viền
          textColor: AppColors.primaryText, // Đổi chữ thành màu đen
          onPressed: () => Get.back(),
        ),
      ],
    );
  }
}
