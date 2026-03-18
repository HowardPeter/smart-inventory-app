// frontend/features/auth/widgets/verify_email/verify_email_form_widget.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/t_image_widget.dart';
import 'package:frontend/core/widgets/t_primary_button_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/features/auth/controllers/verify_email_controller.dart';

// Widget này là GetView<Controller> để dễ dàng gọi logic
class VerifyEmailFormWidget extends GetView<VerifyEmailController> {
  const VerifyEmailFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Tiêu đề nhỏ bên trong chuẩn thiết kế
        Text(
          TTexts.verifyEmailInnerTitle.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppSizes.p24),

        // 2. Ảnh minh hoạ dùng TImageWidget
        TImageWidget(
          image: TImages.authImages.verifyEmailContent1,
          height: 180,
        ),
        const SizedBox(height: AppSizes.p24),

        // 3. Đoạn Text RichText có bôi đậm Email (RichText để inline email in đậm)
        RichText(
          textAlign: TextAlign.justify, // Canh đều 2 bên
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.subText,
              height: 1.5, // Tăng khoảng cách dòng
            ),
            children: [
              TextSpan(text: TTexts.verifyEmailMessageP1.tr),
              TextSpan(
                // Controller tự động móc email từ Arguments ra khi Init
                text: controller.email,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText, // In đậm email nổi bật
                ),
              ),
              TextSpan(text: TTexts.verifyEmailMessageP2.tr),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.p32),

        // 4. Nút Go to Gmail dùng TPrimaryButton
        TPrimaryButton(
          text: TTexts.goToGmail.tr,
          onPressed: controller.openMailApp,
          height: 52,
        ),
        const SizedBox(height: AppSizes.p16),

        // 5. Nút Resend Email (Chỉ bấm được khi timer = 0)
        Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                // Logic disable nút nếu chưa đếm xong
                onPressed: controller.timerCountdown.value == 0 &&
                        !controller.isResending.value
                    ? controller.resendEmail
                    : null, // Chặn bấm
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: BorderSide(
                    // Làm mờ viền khi bị disable
                    color: controller.timerCountdown.value == 0
                        ? Colors.grey.shade300
                        : Colors.grey.shade100,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                ),
                child: controller.isResending.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        TTexts.resendEmail.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          // Làm mờ chữ nếu chưa đếm xong
                          color: controller.timerCountdown.value == 0
                              ? AppColors.primaryText
                              : Colors.grey.shade400,
                        ),
                      ),
              ),
            )),
        const SizedBox(height: AppSizes.p16),

        // 6. Dòng chữ đếm ngược 'after 45s' dùng Obx
        Obx(() => controller.timerCountdown.value > 0
            ? RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                  children: [
                    TextSpan(text: TTexts.resendEmailIn.tr),
                    TextSpan(
                      text: '${controller.timerCountdown.value}s',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()), // Ẩn đi khi đếm xong
      ],
    );
  }
}
