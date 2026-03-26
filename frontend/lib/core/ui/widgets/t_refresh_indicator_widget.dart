import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class TRefreshIndicatorWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double edgeOffset;

  const TRefreshIndicatorWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.background,
      strokeWidth: 3.0,
      displacement: 40.0,
      edgeOffset: edgeOffset,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
