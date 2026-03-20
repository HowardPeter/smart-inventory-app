import 'package:flutter/material.dart';
import 'package:frontend/core/layouts/t_responsive_layout.dart';
import 'package:frontend/features/home/views/platform/home_mobile_view.dart';

/// View chính đóng vai trò điều phối Responsive cho module Home
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: HomeMobileScreen()),
    );
  }
}
