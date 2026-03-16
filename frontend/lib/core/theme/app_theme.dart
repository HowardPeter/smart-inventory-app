import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  AppTheme._();

  // Chỉ dùng duy nhất một theme sáng
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins', // Gọi font mặc định từ pubspec.yaml
    brightness: Brightness.light,

    // 1. Cấu hình màu sắc cốt lõi (Flutter sẽ tự dùng các màu này để vẽ các UI khác)
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary, // Cam đậm
      secondary: AppColors.secondPrimary, // Cam nhạt
      surface: AppColors.surface, // Màu nền card (xám nhạt)
      onPrimary: Colors.white, // Chữ màu trắng khi nằm trên nền Cam
      onSurface: AppColors.primaryText, // Chữ đen khi nằm trên nền xám
    ),

    // Màu nền tổng thể của toàn bộ app (trắng tinh)
    scaffoldBackgroundColor: AppColors.background,

    // 2. Cấu hình Component cơ bản (AppBar)
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0, // Bỏ bóng mờ
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.primaryText),
    ),

    // 3. Cấu hình Nút bấm cơ bản (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius12),
        ),
      ),
    ),
  );
}
