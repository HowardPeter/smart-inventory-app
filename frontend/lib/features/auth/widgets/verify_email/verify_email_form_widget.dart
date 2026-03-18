import 'package:flutter/cupertino.dart'; // Thêm dòng này để lấy icon mũi tên
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/widgets/verify_email/verify_email_go_to_gmail_button_widget.dart';
import 'package:frontend/features/auth/widgets/verify_email/verify_email_header_widget.dart';
import 'package:frontend/features/auth/widgets/verify_email/verify_email_message_widget.dart';
import 'package:frontend/features/auth/widgets/verify_email/verify_email_resend_email_button_widget.dart';
import 'package:get/get.dart';

import 'package:frontend/core/widgets/t_primary_button_widget.dart'; // 1. IMPORT WIDGET CỦA BẠN
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/auth/controllers/verify_email_controller.dart';

class VerifyEmailFormWidget extends GetView<VerifyEmailController> {
  const VerifyEmailFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const VerifyEmailHeaderWidget(),
        const SizedBox(height: AppSizes.p24),
        VerifyEmailMessageWidget(email: controller.email),
        const SizedBox(height: AppSizes.p32),
        const VerifyEmailGoToGmailButtonWidget(),
        const SizedBox(height: AppSizes.p16),
        TPrimaryButton(
          text: TTexts.backToLogin.tr,
          isOutlined: true,
          textColor: AppColors.primaryText,
          onPressed: () => Get.offAllNamed(AppRoutes.login),
        ),
        const SizedBox(height: AppSizes.p16),
        const VerifyEmailResendEmailButton(),
        const SizedBox(height: AppSizes.p24),
      ],
    );
  }
}
