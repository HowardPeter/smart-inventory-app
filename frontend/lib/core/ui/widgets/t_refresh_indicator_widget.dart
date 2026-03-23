import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class TRefreshIndicatorWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const TRefreshIndicatorWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary, // Vòng xoay màu cam chủ đạo
      backgroundColor: AppColors.background, // Nền vòng xoay màu trắng
      strokeWidth: 3.0, // Độ dày của vòng xoay
      displacement: 40.0, // Khoảng cách kéo xuống để kích hoạt
      onRefresh: onRefresh,
      child: child,
    );
  }
}
