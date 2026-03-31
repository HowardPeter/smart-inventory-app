import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationCard extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onTap;
  final String timeAgo;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final iconConfig = _getIconConfig(notification.type, isUnread);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius16),
      child: Ink(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.divider.withOpacity(0.5),
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconConfig['bg'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconConfig['icon'],
                size: 24,
                color: iconConfig['color'],
              ),
            ),
            const SizedBox(width: AppSizes.p16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      color: AppColors.primaryText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.subText,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: isUnread ? AppColors.primary : AppColors.softGrey,
                      fontSize: 12,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Unread Dot
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Logic gen Icon tuỳ thuộc loại thông báo
  Map<String, dynamic> _getIconConfig(String type, bool isUnread) {
    switch (type) {
      case 'LOW_STOCK':
        return {
          'icon': Iconsax.box_remove_copy,
          'color': isUnread ? AppColors.stockOut : AppColors.softGrey,
          'bg': isUnread ? AppColors.toastErrorBg : AppColors.surface,
        };
      case 'ORDER_CREATED':
        return {
          'icon': Iconsax.shopping_cart_copy,
          'color': isUnread ? AppColors.stockIn : AppColors.softGrey,
          'bg': isUnread ? AppColors.toastSuccessBg : AppColors.surface,
        };
      case 'SYSTEM':
        return {
          'icon': Iconsax.info_circle_copy,
          'color': isUnread ? AppColors.primary : AppColors.softGrey,
          'bg': isUnread ? AppColors.toastWarningBg : AppColors.surface,
        };
      default:
        return {
          'icon': Iconsax.notification_copy,
          'color': isUnread ? AppColors.secondPrimary : AppColors.softGrey,
          'bg':
              isUnread ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        };
    }
  }
}
