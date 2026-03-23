// lib/features/workspace/widgets/store_selection_card_widget.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class StoreSelectionCardWidget extends StatelessWidget {
  final String title, role;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const StoreSelectionCardWidget(
      {super.key,
      required this.title,
      required this.role,
      required this.icon,
      required this.iconColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      // Bọc Material để tạo hiệu ứng Ripple (Gợn sóng) khi click
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        clipBehavior:
            Clip.antiAlias, // Cắt InkWell không bị tràn ra ngoài góc bo tròn
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.1), // Sóng màu cam nhạt
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.surface, width: 2),
              borderRadius: BorderRadius.circular(AppSizes.radius16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.primaryText)),
                      Text(role,
                          style: const TextStyle(
                              color: AppColors.subText, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3_copy,
                    color: AppColors.softGrey, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
