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

    return Container(
      // NẾU CHƯA ĐỌC: Hiện bóng mờ cực nhẹ và nổi bật lên.
      // NẾU ĐÃ ĐỌC: Mất bóng mờ, chìm vào nền surface để nhường sự chú ý cho thông báo mới.
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      0.03), // Bóng siêu mờ chuẩn phong cách của bạn
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [], // Không có shadow nếu đã đọc
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================
                // 1. ICON BOX (Squircle - Bo góc 12px)
                // =====================================
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconConfig['bg'],
                    // Bo góc 12px giống hệt các icon container trên màn hình Dashboard của bạn
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                  child: Center(
                    child: Icon(
                      iconConfig['icon'],
                      size: 24,
                      color: iconConfig['color'],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p16),

                // =====================================
                // 2. NỘI DUNG TEXT
                // =====================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          // Tiêu đề đậm đen nếu chưa đọc, xám và mỏng đi nếu đã đọc
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: isUnread
                              ? AppColors.primaryText
                              : AppColors.subText,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: isUnread
                              ? AppColors.subText
                              : AppColors.softGrey.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w400,
                          color: isUnread
                              ? AppColors.primary
                              : AppColors.softGrey.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // =====================================
                // 3. CHẤM TRÒN CHƯA ĐỌC (Unread Dot)
                // =====================================
                if (isUnread) ...[
                  const SizedBox(width: AppSizes.p12),
                  Container(
                    margin: const EdgeInsets.only(top: AppSizes.p4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Chấm cam chủ đạo
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================
  // HELPER: Cấu hình Icon & Màu sắc Pastel
  // =====================================
  Map<String, dynamic> _getIconConfig(String type, bool isUnread) {
    // Nếu ĐÃ ĐỌC: Đổi toàn bộ icon về màu xám mờ để giảm sự chú ý
    if (!isUnread) {
      return {
        'icon': Iconsax.notification_bing_copy,
        'color': AppColors.softGrey.withOpacity(0.5),
        'bg': AppColors.surface, // Nền xám F8F9FA
      };
    }

    // Nếu CHƯA ĐỌC: Dùng dải màu Toast siêu đẹp mà bạn đã cấu hình sẵn trong AppColors
    switch (type) {
      case 'LOW_STOCK':
        return {
          'icon': Iconsax.box_remove_copy,
          'color': AppColors.toastErrorGradientEnd, // Màu đỏ pastel
          'bg': AppColors.toastErrorBg,
        };
      case 'ORDER_CREATED':
      case 'IMPORT':
        return {
          'icon': Iconsax.box_add_copy,
          'color': AppColors.toastSuccessGradientEnd, // Màu xanh pastel
          'bg': AppColors.toastSuccessBg,
        };
      case 'SYSTEM':
        return {
          'icon': Iconsax.info_circle_copy,
          'color': AppColors.toastWarningGradientEnd, // Màu vàng cam
          'bg': AppColors.toastWarningBg,
        };
      default:
        return {
          'icon': Iconsax.notification_1_copy,
          'color': AppColors.primary, // Cam đặc trưng
          'bg': AppColors.primary.withOpacity(0.1),
        };
    }
  }
}
