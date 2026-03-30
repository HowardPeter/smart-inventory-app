import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
// THÊM IMPORT STORE SERVICE ĐỂ LẤY ROLE
import 'package:frontend/core/state/services/store_service.dart';

class InventoryHeaderWidget extends StatelessWidget {
  const InventoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  TTexts.inventoryHub.tr,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  TTexts.manageProductsStock.tr,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.subText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.p12),

          // 🟢 BADGE CHỨC VỤ ĐÃ ĐƯỢC CHUYỂN SANG ĐÂY
          Obx(() {
            final storeService = Get.find<StoreService>();
            final role = storeService.currentRole.value.toLowerCase();
            final isManager =
                role == 'manager' || role == 'owner' || role == 'admin';

            final String tooltipMessage = isManager
                ? TTexts.homeRoleManagerTooltip.tr
                : TTexts.homeRoleStaffTooltip.tr;

            final List<Color> gradientColors = isManager
                ? [AppColors.primary, AppColors.secondPrimary]
                : [const Color(0xFFFF9900), const Color(0xFFFFCC00)];

            final IconData roleIcon = isManager
                ? Icons.admin_panel_settings_rounded
                : Icons.badge_rounded;

            return Tooltip(
              message: tooltipMessage,
              triggerMode: TooltipTriggerMode.tap,
              preferBelow: false,
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
