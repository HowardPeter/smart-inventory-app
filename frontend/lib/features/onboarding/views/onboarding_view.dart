import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/onboarding/controllers/onboarding_controller.dart';

// Import tài nguyên Core
import 'package:frontend/core/constants/image_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            children: [
              // Nút Bỏ qua (Skip) ở góc trên phải
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skipPage,
                  child: Text('Bỏ qua'),
                ),
              ),

              const Spacer(), // Đẩy phần nội dung xuống giữa
              // 1. Hình ảnh minh họa (Chiếm khoảng 40% màn hình)
              // Nếu chưa có hình, bạn dùng tạm Image.asset hoặc Icon bự
              Image.asset(
                TImages.onboardingImages.sidePicture,
                height: Get.height * 0.4, // Cần import 'package:get/get.dart'
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.inventory_2_outlined,
                  size: 150,
                  color: AppColors.primary,
                ), // Icon hiện tạm nếu chưa có hình
              ),
              const SizedBox(height: AppSizes.p32),

              // 2. Tiêu đề (Suez One)
              Text('Quản Lý Kho\nDễ Dàng Hơn', textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p16),

              // 3. Mô tả (Poppins)
              Text(
                'Kiểm soát hàng hóa, theo dõi xuất nhập tồn và quét mã vạch nhanh chóng chỉ với một chạm.',
                textAlign: TextAlign.center,
              ),

              const Spacer(), // Đẩy nút bấm xuống đáy
              // 4. Thanh điều hướng (Dấu chấm + Nút Tiếp tục)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dấu chấm (Dots) giả lập cho 3 trang
                  Row(
                    children: [
                      _buildDot(isActive: true),
                      const SizedBox(width: AppSizes.p8),
                      _buildDot(isActive: false),
                      const SizedBox(width: AppSizes.p8),
                      _buildDot(isActive: false),
                    ],
                  ),

                  // Nút Tiếp tục (Ăn theo style màu Cam ở app_theme)
                  ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(), // Biến nút thành hình tròn
                      padding: const EdgeInsets.all(AppSizes.p16),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16), // Cách đáy một chút
            ],
          ),
        ),
      ),
    );
  }

  // Widget vẽ dấu chấm (Dot)
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8, // Chấm đang chọn sẽ dài ra
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radius8),
      ),
    );
  }
}
