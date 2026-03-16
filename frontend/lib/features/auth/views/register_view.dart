import 'package:flutter/material.dart';
import 'package:frontend/core/layouts/t_responsive_layout.dart';
import 'package:frontend/features/auth/views/platform/register_mobile_view.dart';

/// View chính đóng vai trò điều phối Responsive cho module Register
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: RegisterMobileView()),
    );
  }
}
