import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

/// Hộp thoại (Dialog) tùy chỉnh tái sử dụng (Chuẩn UI UI/UX xếp dọc)
class TCustomDialog extends StatelessWidget {
  const TCustomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  final String title;
  final String description;
  final Widget icon;

  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;

  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Bo góc viền Dialog siêu mượt như thiết kế
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      backgroundColor: AppColors.white, // Nền trắng toàn bộ
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==========================================
            // 1. KHUNG CHỨA ICON (Nền xám nhạt bo góc)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: AppColors.surface, // Lấy chuẩn màu F8F9FA từ AppColors
                borderRadius: BorderRadius.circular(AppSizes.radius16),
              ),
              child: icon,
            ),
            const SizedBox(height: AppSizes.p24),

            // ==========================================
            // 2. TIÊU ĐỀ & MÔ TẢ
            // ==========================================
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p12),

            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.subText, // Lấy màu xám chuẩn từ AppColors
                height: 1.5, // Giãn dòng cho dễ đọc như hình
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p32),

            // ==========================================
            // 3. KHU VỰC NÚT BẤM (Xếp Dọc - Full Width)
            // ==========================================

            // NÚT CHÍNH (Màu Cam)
            SizedBox(
              width: double.infinity, // Kéo giãn hết chiều ngang
              child: ElevatedButton(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                ),
                child: Text(
                  primaryButtonText,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16, // Chữ to và đậm hơn một chút
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // NÚT PHỤ (Chỉ hiển thị nếu có truyền text vào)
            if (secondaryButtonText != null) ...[
              const SizedBox(height: AppSizes.p12), // Khoảng cách giữa 2 nút

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSecondaryPressed ?? () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.surface, // Nền xám nhạt như hình
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                  ),
                  child: Text(
                    secondaryButtonText!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText, // Chữ màu đen đậm như hình
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
