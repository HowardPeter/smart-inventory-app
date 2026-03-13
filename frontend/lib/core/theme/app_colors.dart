import 'package:flutter/material.dart';

class AppColors {
  // Không cho phép khởi tạo class này
  AppColors._();

  // Màu chủ đạo
  static const Color primary = Color(0xFFFF8A00);
  static const Color secondPrimary = Color(0xFFFFB057);

  // Màu nền và Card
  static const Color surface = Color(0xFFF8F9FA);
  static const Color background = Color(
    0xFFFFFFFF,
  ); // Thêm trắng tinh cho nền dưới cùng

  // Màu chữ
  static const Color primaryText = Color(0xFF1A1C23);
  static const Color subText = Color(0xFF6C757D);

  // Màu trạng thái
  static const Color success = Color(0xFF28A745);
  static const Color failed = Color(0xFFDC3545);
}
