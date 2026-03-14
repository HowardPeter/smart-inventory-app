import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/t_image_widget.dart.dart';
import 'package:get/get.dart';

import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import '../controllers/splash_controller.dart';
import '../widgets/splash_loading_bar.dart';
import '../widgets/splash_footer.dart';

/// Màn hình Splash: Entry point của ứng dụng
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TImageWidget(image: TImages.appLogos.appLogo, width: 200),
                const SizedBox(height: AppSizes.p16),

                Text(
                  'Smart Inventory, Smarter Business',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryText.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 60),

                // Thanh loading bar đã được tách riêng
                const SplashLoadingBar(),
              ],
            ),
          ),

          // Phần thông tin Team & Version đã được tách riêng
          const SplashFooter(),
        ],
      ),
    );
  }
}
