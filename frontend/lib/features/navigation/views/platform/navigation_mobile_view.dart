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
      backgroundColor: Colors.transparent, // Dùng chuẩn AppColors
      extendBody: true,
      // 1. CHỨA CÁC MÀN HÌNH BÊN TRONG
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: const [
              HomeView(), // Tab 0: Home
              Center(child: Text('Inventory Screen')), // Tab 1
              Center(child: Text('Transaction / Scan')), // Tab 2 (Nút giữa)
              Center(child: Text('Reports')), // Tab 3
              Center(child: Text('Profile')), // Tab 4
            ],
          )),

      // 2. THANH ĐIỀU HƯỚNG CUSTOM
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // NỀN NAV
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surface, // Dùng màu nền bề mặt chuẩn
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
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Iconsax.home_2_copy,
                      currentIndex: controller.selectedIndex.value,
                      onTap: () => controller.changeIndex(0),
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Iconsax.box_copy,
                      currentIndex: controller.selectedIndex.value,
                      onTap: () => controller.changeIndex(1),
                    ),
                    const SizedBox(width: 70), // Khoảng trống cho nút giữa
                    _buildNavItem(
                      index: 3,
                      icon: Iconsax.chart_21_copy,
                      currentIndex: controller.selectedIndex.value,
                      onTap: () => controller.changeIndex(3),
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Iconsax.user_copy,
                      currentIndex: controller.selectedIndex.value,
                      onTap: () => controller.changeIndex(4),
                    ),
                  ],
                ),
              ),
            ),

            // NÚT GIỮA (Nổi lên và viền đè)
            Positioned(
              top: -16,
              child: GestureDetector(
                onTap: () => controller.changeIndex(2),
                child: Obx(() => AnimatedScale(
                      scale: 1.1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.secondPrimary,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.surface,
                            width: 6,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HÀM VẼ CÁC TAB
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            // Dùng AppColors.primaryText cho nền đen khi chọn
            color: isSelected ? AppColors.primaryText : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            // Dùng AppColors.primary (Cam) và AppColors.softGrey (Xám nhạt)
            color: isSelected ? AppColors.primary : AppColors.softGrey,
            size: 24,
          ),
        ),
      ),
    );
  }
}
