import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/inventory/views/inventory_view.dart';
import 'package:frontend/features/profile/views/profile_view.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:frontend/features/home/views/home_view.dart';

class NavigationMobileView extends GetView<NavigationController> {
  const NavigationMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. CHỨA CÁC MÀN HÌNH BÊN TRONG
          Obx(() {
            final index = controller.selectedIndex.value;
            Widget currentScreen;

            switch (index) {
              case 0:
                currentScreen = const HomeView();
                break;
              case 1:
                currentScreen = const InventoryView();
                break;
              case 2:
                currentScreen = const Center(child: Text('Transaction / Scan'));
                break;
              case 3:
                currentScreen = const Center(child: Text('Reports'));
                break;
              case 4:
                currentScreen = const ProfileView();
                break;
              default:
                currentScreen = const SizedBox.shrink();
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey<int>(
                    index), // Bắt buộc có Key để Flutter biết đã đổi màn hình
                child: currentScreen,
              ),
            );
          }),

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
                    height: AppSizes.bottomNavHeight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: AppSizes.radius20,
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
                      // ĐÃ SỬA: Bấm vào thì hiện Bottom Sheet thay vì đổi tab
                      onTap: () {
                        TBottomSheetWidget.show(
                          title: TTexts.createNewTransaction.tr,
                          child: const TransactionBottomSheetWidget(),
                        );
                      },
                      // Giữ nguyên giao diện nút giữa của bạn
                      child: Obx(() {
                        final isSelected = controller.selectedIndex.value == 2;
                        return AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondPrimary
                                ],
                              ),
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
                            child: Center(
                              child: Image.asset(
                                TImages.iconImages.plusIcon,
                                width: 26,
                                height: 26,
                                color: AppColors.white,
                              ),
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
