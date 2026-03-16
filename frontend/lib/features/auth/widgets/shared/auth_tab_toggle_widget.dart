import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

class AuthTabToggleWidget extends StatelessWidget {
  const AuthTabToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // Cố định chiều cao cho thanh thoát
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Màu nền xám cực nhẹ
        borderRadius: BorderRadius.circular(
          AppSizes.radius12,
        ), // Bo góc mềm hơn
      ),
      child: Row(
        children: [
          // Nút Log In (Đang chọn)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.04,
                    ), // Bóng cực mờ, sang trọng
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  TTexts.loginTab.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ),

          // Nút Sign Up (Chưa chọn)
          Expanded(
            child: Center(
              child: Text(
                TTexts.signupTab.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.subText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
