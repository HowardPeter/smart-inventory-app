import 'package:flutter/material.dart';
import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:frontend/features/auth/widgets/forgot_password/forgot_password_form_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';

/// Màn hình đăng nhập Mobile áp dụng AuthStandardLayout
class ForgotPasswordMobileView extends GetView<LoginController> {
  const ForgotPasswordMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStandardLayout(
      title: TTexts.forgetPasswordTitle.tr,
      subtitle: TTexts.forgetPasswordSubtitle.tr,
      showBackButton: false,
      child: const ForgotPasswordFormWidget(),
    );
  }
}
