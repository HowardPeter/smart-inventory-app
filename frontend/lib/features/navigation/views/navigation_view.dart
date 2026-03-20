import 'package:flutter/material.dart';
import 'package:frontend/core/layouts/t_responsive_layout.dart';
import 'package:frontend/features/navigation/views/platform/navigation_mobile_view.dart';

/// View chính đóng vai trò điều phối Responsive cho module Onboarding
class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Sử dụng TResponsiveLayout để nạp đúng View theo thiết bị
      body: TResponsiveLayout(mobile: NavigationMobileView()),
    );
  }
}
