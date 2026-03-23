import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'platform/splash_mobile_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: TResponsiveLayout(mobile: SplashMobileView()),
    );
  }
}
