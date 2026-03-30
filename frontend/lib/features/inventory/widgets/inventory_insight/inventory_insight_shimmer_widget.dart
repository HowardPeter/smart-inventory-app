import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class InventoryInsightShimmerWidget extends StatelessWidget {
  final double topOffset;

  const InventoryInsightShimmerWidget({super.key, required this.topOffset});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topOffset + 16),
          // 1. Tổng số Item (Giả)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBlock(width: 120, height: 16, radius: 4),
                const SizedBox(height: 8),
                _buildBlock(width: 180, height: 36, radius: 8),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // 2. Overview Cards (3 Thẻ ngang)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            child: Row(
              children: [
                Expanded(child: _buildBlock(height: 110, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _buildBlock(height: 110, radius: 16)),
                const SizedBox(width: 12),
                Expanded(child: _buildBlock(height: 110, radius: 16)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // 3. Category Chips (Giả lập cuộn ngang)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            child: Row(
              children: [
                _buildBlock(width: 80, height: 40, radius: 20),
                const SizedBox(width: 8),
                _buildBlock(width: 100, height: 40, radius: 20),
                const SizedBox(width: 8),
                _buildBlock(width: 120, height: 40, radius: 20),
                const SizedBox(width: 8),
                Expanded(child: _buildBlock(height: 40, radius: 20)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // 4. Danh sách Items (Giả lập list dọc)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
            child: Column(
              children: [
                _buildBlock(width: double.infinity, height: 90, radius: 16),
                const SizedBox(height: 12),
                _buildBlock(width: double.infinity, height: 90, radius: 16),
                const SizedBox(height: 12),
                _buildBlock(width: double.infinity, height: 90, radius: 16),
                const SizedBox(height: 12),
                _buildBlock(width: double.infinity, height: 90, radius: 16),
                const SizedBox(height: 12),
                _buildBlock(width: double.infinity, height: 90, radius: 16),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBlock(
      {double width = double.infinity,
      required double height,
      required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.3), // Màu xám nhạt
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
