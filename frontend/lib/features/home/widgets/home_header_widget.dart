import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/core/controllers/user_controller.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final fullName =
                      userController.currentUser.value?.fullName ?? 'Guest';
                  final firstName = fullName.trim().split(' ').last;

                  return Text(
                    '${homeController.greetingText}, $firstName',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
                const SizedBox(height: 2),
                Text(
                  TTexts.homeDailyOverview.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.p12),

          // BADGE ROLE VỚI TOOLTIP ĐỘNG TỪ TTEXTS
          Obx(() {
            final role =
                userController.currentUser.value?.role.toLowerCase() ?? 'staff';
            final isManager = role == 'manager' || role == 'admin';

            // Lấy nội dung Tooltip từ TTexts
            final String tooltipMessage = isManager
                ? TTexts.homeRoleManagerTooltip.tr
                : TTexts.homeRoleStaffTooltip.tr;

            // Định nghĩa Gradient & Icon
            final List<Color> gradientColors = isManager
                ? [AppColors.primary, AppColors.secondPrimary]
                : [const Color(0xFFFF9900), const Color(0xFFFFCC00)];

            final IconData roleIcon = isManager
                ? Icons.admin_panel_settings_rounded
                : Icons.badge_rounded;

            return Tooltip(
              message: tooltipMessage, // Hiển thị tooltip dựa trên role
              triggerMode:
                  TooltipTriggerMode.tap, // Chạm vào là hiện ngay trên mobile
              preferBelow: false, // Hiện phía trên icon cho đỡ vướng tay
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(roleIcon, color: Colors.white, size: 26),
              ),
            );
          }),
        ],
      ),
    );
  }
}
