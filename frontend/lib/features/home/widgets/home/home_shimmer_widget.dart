import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class HomeShimmerWidget extends StatelessWidget {
  const HomeShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.p8),
        // Khung chờ cho Biểu đồ doanh thu
        _buildSkeleton(height: 220, radius: AppSizes.radius24),
        const SizedBox(height: AppSizes.p32),

        // Khung chờ cho Quick Actions
        _buildSkeleton(height: 100, radius: AppSizes.radius24),
        const SizedBox(height: AppSizes.p32),

        // Khung chờ cho Daily Summary
        _buildSkeleton(height: 200, radius: AppSizes.radius24),
        const SizedBox(height: AppSizes.p32),

        // Khung chờ cho List
        _buildSkeleton(height: 150, radius: AppSizes.radius24),
      ],
    );
  }

  Widget _buildSkeleton({required double height, required double radius}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        // Sử dụng màu nền xám mờ làm khung xương loading
        color: AppColors.softGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
