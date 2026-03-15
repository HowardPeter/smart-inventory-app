import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/core/widgets/t_image_widget.dart';

import '../../widgets/splash_footer.dart';
import '../../widgets/splash_loading_bar.dart';

/// Layout dành riêng cho màn hình điện thoại
class SplashMobileView extends StatelessWidget {
  const SplashMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Nội dung trung tâm (Logo, Slogan, Loading)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo SI
              TImageWidget(image: TImages.appLogos.appLogo, width: 200),

              const SizedBox(height: AppSizes.p16),

              // Slogan (Sử dụng Localization)
              Text(
                TTexts.splashSlogan.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryText.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 60),

              // Thanh loading bar đã tối ưu với LayoutBuilder
              const SizedBox(
                width: 250, // Giới hạn chiều rộng thanh load trên mobile
                child: SplashLoadingBar(),
              ),
            ],
          ),
        ),

        // 2. Thông tin Team & Version ở dưới cùng
        const SplashFooter(),
      ],
    );
  }
}
