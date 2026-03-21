import 'package:flutter/material.dart';
import 'package:frontend/features/splash/widgets/splash_moving_box_widget.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashLoadingBar extends GetView<SplashController> {
  const SplashLoadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double maxBarWidth = MediaQuery.of(context).size.width * 0.6;

    return Obx(() {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: controller.progress.value),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final double currentPosition = maxBarWidth * value;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Nền thanh load
              Container(
                height: 4,
                width: maxBarWidth,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Thanh load chính
              Container(
                height: 4,
                width: currentPosition,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),

              // Chiếc hộp di chuyển
              Positioned(
                left: currentPosition - 15,
                top: -28,
                child: SplashMovingBoxWidget(
                  isMoving: value < controller.progress.value,
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
