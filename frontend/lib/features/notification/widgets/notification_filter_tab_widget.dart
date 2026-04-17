import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:get/get.dart';

class NotificationFilterTabWidget extends StatelessWidget {
  const NotificationFilterTabWidget({
    super.key,
    required this.controller,
  });

  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterChip(
              'Tất cả', 'ALL', controller), // Hoặc dùng TTexts.filterAll.tr
          const SizedBox(width: 8),

          // Nhóm Cảnh báo & Tồn kho
          _buildFilterChip('Sắp hết hàng', 'LOW_STOCK', controller),
          const SizedBox(width: 8),
          _buildFilterChip('Lệch kho', 'DISCREPANCY_ALERT', controller),
          const SizedBox(width: 8),
          _buildFilterChip('Gợi ý nhập', 'REORDER_SUGGESTION', controller),
          const SizedBox(width: 8),

          // Nhóm Giao dịch
          _buildFilterChip('Nhập kho', 'IMPORT', controller),
          const SizedBox(width: 8),
          _buildFilterChip('Xuất kho', 'EXPORT', controller),
          const SizedBox(width: 8),

          // Nhóm Hệ thống
          _buildFilterChip('Hệ thống', 'ROLE_UPDATED', controller),
        ],
      ),
    );
  }
}

Widget _buildFilterChip(
    String label, String value, NotificationController controller) {
  return Obx(() {
    final isSelected = controller.selectedFilter.value == value;
    return InkWell(
      onTap: () => controller.changeFilter(value),
      borderRadius: BorderRadius.circular(AppSizes.radius24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.subText,
          ),
        ),
      ),
    );
  });
}
