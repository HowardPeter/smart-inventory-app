import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/auth/views/platform/forgot_password_mobile_view.dart';

/// View chính đóng vai trò điều phối Responsive cho module ForgotPassword
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Sử dụng TResponsiveLayout để nạp đúng View theo thiết bị
      body: TResponsiveLayout(mobile: ForgotPasswordMobileView()),
    );
  }
}
