import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

/// Widget hiển thị thẻ Loading bo góc có chữ
class TAnimationLoaderWidget extends StatelessWidget {
  const TAnimationLoaderWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
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
          mainAxisSize: MainAxisSize.min, // Vừa đủ bọc nội dung
          children: [
            // Vòng xoay tuỳ chỉnh màu sắc
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: AppSizes.p16),
            // Dòng chữ trạng thái
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
                decoration: TextDecoration
                    .none, // Bắt buộc vì nó nằm trong Dialog (không có Scaffold)
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
