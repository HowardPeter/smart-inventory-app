import 'package:flutter/material.dart';
import 'package:frontend/core/layouts/t_responsive_layout.dart';
import 'package:frontend/features/onboarding/views/platform/onboarding_mobile_view.dart';

/// View chính đóng vai trò điều phối Responsive cho module Onboarding
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Sử dụng TResponsiveLayout để nạp đúng View theo thiết bị
      body: TResponsiveLayout(mobile: OnboardingMobileView()),
    );
  }
}
