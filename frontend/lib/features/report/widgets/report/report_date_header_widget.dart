import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:get/get.dart';

class ReportDateHeaderWidget extends GetView<ReportController> {
  const ReportDateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.currentDateStr, // Lấy ngày hôm nay
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 34, // Tăng size to lên
                color: AppColors.primaryText,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 2), // Ép khoảng cách chữ chuẩn chỉnh
          Text(
            controller.currentDayStr, // Lấy thứ hôm nay
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18, // Tăng size to lên
                color: AppColors.subText.withOpacity(0.8),
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
