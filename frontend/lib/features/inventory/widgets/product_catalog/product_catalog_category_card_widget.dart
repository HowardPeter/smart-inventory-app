import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductCatalogCategoryCardWidget extends StatelessWidget {
  const ProductCatalogCategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
  });

  final CategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          // Bóng đổ nhẹ cho thẻ sang trọng
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Icon cảnh báo (Sử dụng Poppins + Gradient)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface, // Màu nền xám nhẹ của bạn
                borderRadius: BorderRadius.circular(10),
              ),
              child: const GradientIcon(
                Iconsax.box_search_copy,
                size: 24,
                gradient: LinearGradient(
                  colors: [AppColors.secondPrimary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // 2. Tên danh mục (Đẹp, Đậm)
            Text(
              category.name.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),

            // 3. Mô tả danh mục
            Text(
              category.description?.tr ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 1.4,
                color: AppColors.subText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget phụ để vẽ Icon có Gradient
class GradientIcon extends StatelessWidget {
  const GradientIcon(
    this.icon, {
    super.key,
    this.size,
    required this.gradient,
  });

  final IconData icon;
  final double? size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: SizedBox(
        width: size! * 1.2,
        height: size! * 1.2,
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, bounds.width, bounds.height);
        return gradient.createShader(rect);
      },
    );
  }
}
