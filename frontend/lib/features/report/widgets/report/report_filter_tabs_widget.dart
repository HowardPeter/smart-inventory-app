import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';

class ReportFilterTabsWidget extends GetView<ReportController> {
  const ReportFilterTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Obx(() => Row(
            children: [
              _buildTab('Today', controller.activeTab.value == 'Today'),
              const SizedBox(width: 12),
              _buildTab('Calendar', controller.activeTab.value == 'Calendar'),
            ],
          )),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return GestureDetector(
      onTap: () => controller.changeTab(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          // GRADIENT ĐEN CHO TAB ACTIVE
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gradientBlackStart,
                    AppColors.gradientBlackEnd
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.softGrey.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            color: isActive ? Colors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
