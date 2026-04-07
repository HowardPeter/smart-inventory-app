import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class AssignsRoleSearchWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;

  const AssignsRoleSearchWidget({
    super.key,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          boxShadow: [
            BoxShadow(
              color: AppColors.softGrey.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSizes.p16),
            const Icon(
              Iconsax.search_normal_copy,
              color: AppColors.softGrey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText,
                style: const TextStyle(
                  color: AppColors.softGrey,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Đã xóa phần Container chứa nút Scan và gradient
            const SizedBox(
                width: AppSizes.p16), // Thêm khoảng đệm ở cuối cho cân đối
          ],
        ),
      ),
    );
  }
}
