import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class ProductCatalogCategoryListItemWidget extends StatelessWidget {
  const ProductCatalogCategoryListItemWidget({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  final CategoryModel category;
  final int index; // Dùng để tính màu
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Bảng màu y chang màn hình Home
    final List<Color> avatarColors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo
    ];

    final String name = category.name;
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "?";
    final Color bgColor = avatarColors[index % avatarColors.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p12),
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          border: Border.all(color: AppColors.softGrey.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Căn giữa theo chiều dọc
          children: [
            // Avatar cục vuông màu mè
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                firstLetter,
                style: TextStyle(
                  color: bgColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p16),

            // Text Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (category.description != null &&
                            category.description!.isNotEmpty)
                        ? category.description!
                        : TTexts.noCategoryDescription.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.p8),

            // Icon mui tên bên phải
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.softGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
