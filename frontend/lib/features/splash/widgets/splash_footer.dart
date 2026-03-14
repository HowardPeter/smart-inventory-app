import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

class SplashFooter extends StatelessWidget {
  const SplashFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSizes.p32,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'Version 1.0.0', // [cite: 16]
            style: TextStyle(
              color: AppColors.primaryText.withOpacity(0.3),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Developed by Group 21', // [cite: 6]
            style: TextStyle(
              color: AppColors.primaryText.withOpacity(0.5),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
