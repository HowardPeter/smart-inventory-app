import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/controllers/profile_assigns_role_controller.dart';
import 'package:get/get.dart';

class AssignsRoleTabWidget extends StatelessWidget {
  const AssignsRoleTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileAssignsRoleController>();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTab(controller, 0, TTexts.assignsRoleAll.tr),
          _buildTab(controller, 1, TTexts.assignsRoleOwner.tr),
          _buildTab(controller, 2, TTexts.assignsRoleManager.tr),
          _buildTab(controller, 3, TTexts.assignsRoleStaff.tr),
        ],
      ),
    );
  }

  Widget _buildTab(
      ProfileAssignsRoleController controller, int index, String label) {
    return Obx(() {
      final isActive = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: AppSizes.p8),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.softGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius24),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.subText,
            ),
          ),
        ),
      );
    });
  }
}
