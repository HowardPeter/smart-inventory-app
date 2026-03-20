import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:frontend/features/home/views/home_view.dart';

class NavigationMobileView extends StatelessWidget {
  const NavigationMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. CHỨA CÁC MÀN HÌNH BÊN TRONG
          Obx(() => IndexedStack(
                index: controller.selectedIndex.value,
                children: const [
                  HomeView(), // Tab 0: Home
                  Center(child: Text('Inventory Screen')), // Tab 1
                  Center(child: Text('Transaction / Scan')), // Tab 2
                  Center(child: Text('Reports')), // Tab 3
                  Center(child: Text('Profile')), // Tab 4
                ],
              )),

          // 2. THANH ĐIỀU HƯỚNG OVERLAY
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 110,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // NỀN NAV (Không dùng Obx ở đây nữa)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Truyền thẳng controller vào để nó tự xử lý Obx bên trong
                        _buildNavItem(
                            index: 0,
                            icon: Iconsax.home_2_copy,
                            controller: controller),
                        _buildNavItem(
                            index: 1,
                            icon: Iconsax.box_copy,
                            controller: controller),
                        const SizedBox(width: 70), // Khoảng trống cho nút giữa
                        _buildNavItem(
                            index: 3,
                            icon: Iconsax.chart_21_copy,
                            controller: controller),
                        _buildNavItem(
                            index: 4,
                            icon: Iconsax.user_copy,
                            controller: controller),
                      ],
                    ),
                  ),

                  // NÚT GIỮA
                  Positioned(
                    bottom: 30,
                    child: GestureDetector(
                      onTap: () => controller.changeIndex(2),
                      child: Obx(() {
                        // Bọc Obx sát nhất có thể
                        final isSelected = controller.selectedIndex.value == 2;
                        return AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HÀM VẼ CÁC TAB ĐÃ ĐƯỢC TỐI ƯU OBX
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required NavigationController
        controller, // Nhận controller thay vì giá trị cứng
  }) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      // Đặt Obx ở đây, nó chỉ build lại duy nhất cái nút này khi index thay đổi
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;

        return AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryText : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.softGrey,
              size: 24,
            ),
          ),
        );
      }),
    );
  }
}
