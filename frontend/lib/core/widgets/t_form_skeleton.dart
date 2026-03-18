import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

/// Hiệu ứng khung xương tải form (Skeleton)
class TFormSkeleton extends StatelessWidget {
  const TFormSkeleton({super.key, this.itemCount = 3});

  final int itemCount; // Số lượng ô textfield giả muốn hiển thị

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tạo ra các ô nhập liệu giả
        ...List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chữ tiêu đề giả (Label)
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surface, // Màu xám nhạt
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                // Ô input giả
                Container(
                  width: double.infinity,
                  height: 56, // Chiều cao chuẩn của TextField
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSizes.p16),

        // Nút bấm giả (Button)
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius12),
          ),
        ),
      ],
    );
  }
}
