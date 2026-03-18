import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

/// Widget nút điều hướng tiếp theo trong màn hình Onboarding
/// Bao gồm hiệu ứng xoay 360 độ và thanh tiến trình vòng tròn co giãn
class OnboardingNextButtonWidget extends StatefulWidget {
  // 1. Final variables
  final VoidCallback onTap;
  final double progress;
  final double startingAngle;
  final IconData icon;

  // 2. Constructor
  const OnboardingNextButtonWidget({
    super.key,
    required this.onTap,
    this.progress = 0.33,
    this.startingAngle = 0.0,
    this.icon = Icons.arrow_forward_ios_rounded,
  });

  @override
  State<OnboardingNextButtonWidget> createState() =>
      _OnboardingNextButtonWidgetState();
}

class _OnboardingNextButtonWidgetState extends State<OnboardingNextButtonWidget>
    with SingleTickerProviderStateMixin {
  // 1. Animation variables
  late AnimationController _animationController;

  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 3. Private methods
  Future<void> _handleTap() async {
    // Đợi hiệu ứng xoay hoàn tất trước khi chuyển trang
    await _animationController.forward(from: 0.0);
    widget.onTap();
  }

  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Transform.rotate(
              angle: widget.startingAngle * math.pi / 180,
              child: SizedBox(
                width: 68,
                height: 68,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: widget.progress),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 4,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _handleTap,
                customBorder: const CircleBorder(),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.transparent,
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: AppSizes.iconMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
