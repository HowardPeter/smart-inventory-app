import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class InventoryDashboardShimmerWidget extends StatelessWidget {
  const InventoryDashboardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header giả (Avatar & Welcome)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBlock(width: 150, height: 24, radius: 4),
                _buildBlock(width: 40, height: 40, radius: 20),
              ],
            ),
            const SizedBox(height: AppSizes.p24),
            // Search bar giả
            _buildBlock(width: double.infinity, height: 50, radius: 12),
            const SizedBox(height: AppSizes.p24),
            // Flow Chart giả
            _buildBlock(width: double.infinity, height: 180, radius: 16),
            const SizedBox(height: AppSizes.p24),
            // Stock Insights giả (2 thẻ ngang)
            Row(
              children: [
                Expanded(child: _buildBlock(height: 100, radius: 16)),
                const SizedBox(width: 16),
                Expanded(child: _buildBlock(height: 100, radius: 16)),
              ],
            ),
            const SizedBox(height: AppSizes.p32),
            // Tiêu đề Catalog giả
            _buildBlock(width: 140, height: 20, radius: 4),
            const SizedBox(height: 12),
            // Categories giả (List item)
            _buildBlock(width: double.infinity, height: 70, radius: 16),
            const SizedBox(height: 12),
            _buildBlock(width: double.infinity, height: 70, radius: 16),
            const SizedBox(height: 12),
            _buildBlock(width: double.infinity, height: 70, radius: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock({double width = double.infinity, required double height, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}