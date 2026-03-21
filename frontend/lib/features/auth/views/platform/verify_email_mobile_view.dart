import 'package:flutter/material.dart';
import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:frontend/features/auth/widgets/verify_email/verify_email_form_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';

/// Màn hình đăng nhập Mobile áp dụng AuthStandardLayout
class VerifyEmailMobileView extends GetView<LoginController> {
  const VerifyEmailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStandardLayout(
      title: TTexts.verifyEmailTitle.tr,
      subtitle: TTexts.verifyEmailSubtitle.tr,
      showBackButton: false,
      child: const VerifyEmailFormWidget(),
    );
  }
}
