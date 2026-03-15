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
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 60, // Chiều cao tiêu chuẩn cho nút bấm lớn
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius12),
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
                fontSize: 18,
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
