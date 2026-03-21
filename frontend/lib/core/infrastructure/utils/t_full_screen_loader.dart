import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Thư viện để xài UI chuẩn iOS
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

/// Lớp tiện ích gộp chung UI và Logic Loading
class TFullScreenLoader {
  /// Mở hộp thoại Loading
  static void openLoadingDialog(String text) {
    Get.dialog(
      PopScope(
        canPop: false, // Chặn nút Back của Android
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p32,
              vertical: AppSizes.p24,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tự động co bóp theo nội dung
              children: [
                // Vòng xoay cánh hoa chuẩn iOS (Mượt và sang hơn rất nhiều)
                const CupertinoActivityIndicator(
                  radius: 18,
                  color: AppColors.primary, // Đổi sang màu cam/chủ đạo của App
                ),
                const SizedBox(height: AppSizes.p16),
                // Chữ hiển thị
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                    decoration:
                        TextDecoration.none, // Bắt buộc khi dùng Get.dialog
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      // 2 DÒNG NÀY LÀ CHÌA KHÓA GIẢI QUYẾT LỖI STATUS BAR KHÔNG BỊ MỜ
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(
        0.6,
      ), // Màu nền mờ phủ toàn màn hình
      useSafeArea: false, // Ép phủ lên cả Status Bar và Bottom Navigation
    );
  }

  /// Đóng hộp thoại Loading
  static void stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
