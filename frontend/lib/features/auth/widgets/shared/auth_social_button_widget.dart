import 'package:flutter/material.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

/// Nút đăng nhập bằng mạng xã hội (Google)
class AuthSocialButtonWidget extends GetView<LoginController> {
  const AuthSocialButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Chiều cao đồng bộ với TPrimaryButton
      child: OutlinedButton(
        onPressed: () => controller.loginWithGoogle(),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(
            color: Colors.grey.shade300,
          ), // Viền xám nhạt theo Figma
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Logo Google
            Image.asset(TImages.appLogos.googleLogo, height: 24, width: 24),

            const SizedBox(width: AppSizes.p24),

            // 2. Tiêu đề nút
            Text(
              TTexts.continueWithGoogle.tr,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
