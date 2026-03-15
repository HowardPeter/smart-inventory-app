import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Widget chiếc hộp hàng hóa với hiệu ứng nghiêng (tilt) khi di chuyển
class SplashMovingBoxWidget extends StatelessWidget {
  /// Trạng thái xác định hộp có đang trong quá trình di chuyển hay không
  final bool isMoving;

  const SplashMovingBoxWidget({super.key, required this.isMoving});

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      // Khi di chuyển (isMoving = true), hộp sẽ nghiêng nhẹ 1 góc (0.01 turns ≈ 3.6 độ)
      turns: isMoving ? 0.01 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Icon hàng hóa chính
          const Icon(
            Icons.inventory_2_rounded,
            size: 26,
            color: AppColors.primary,
          ),

          const SizedBox(height: 2),

          // 2. Hiệu ứng bóng đổ (Shadow) động dưới chân hộp
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            // Khi di chuyển, bóng đổ sẽ dài ra một chút để tạo cảm giác động lực học
            width: isMoving ? 18 : 12,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
