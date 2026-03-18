import 'package:flutter/material.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/features/auth/widgets/register/register_form_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:frontend/features/auth/controllers/register_controller.dart';

class RegisterMobileView extends GetView<RegisterController> {
  const RegisterMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStandardLayout(
      title: TTexts.registerTitle.tr,
      subtitle: TTexts.registerSubtitle.tr,
      showBackButton: false,
      child: const RegisterFormWidget(),
    );
  }
}
