import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

class TPrimaryButton extends StatelessWidget {
  const TPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.primary, // Mặc định dùng màu cam SI
    this.textColor = Colors.white,
    this.width = double.infinity, // Mặc định trải dài toàn màn hình
    this.height = 60.0, // Thêm tùy chỉnh chiều cao
    this.borderRadius = AppSizes.radius12, // Thêm tùy chỉnh độ bo góc
    this.fontSize = 14.0, // Thêm tùy chỉnh cỡ chữ
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height; // Khai báo biến
  final double borderRadius; // Khai báo biến
  final double fontSize; // Khai báo biến

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height, // Gắn biến height vào đây
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ), // Gắn biến borderRadius vào đây
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Icon nằm bên trái (nếu có)
            if (icon != null)
              Positioned(
                left: 0,
                child: Icon(icon, size: AppSizes.iconMd, color: textColor),
              ),

            // 2. Chữ nằm chính giữa
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: fontSize, // Gắn biến fontSize vào đây
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
