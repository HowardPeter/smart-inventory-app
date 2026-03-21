import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'platform/splash_mobile_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: TResponsiveLayout(mobile: SplashMobileView()),
    );
  }
}
