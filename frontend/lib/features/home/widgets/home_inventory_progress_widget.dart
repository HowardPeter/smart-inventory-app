import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeInventoryProgressWidget extends GetView<HomeController> {
  const HomeInventoryProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 12,
        child: Obx(() {
          final inStock = controller.stockInToday;
          final outStock = controller.stockOutToday;
          final total = inStock + outStock;

          // Nếu không có dữ liệu, chia đôi 50-50
          final int flexIn = total > 0 ? ((inStock / total) * 100).toInt() : 50;
          final int flexOut = total > 0 ? 100 - flexIn : 50;

          return Row(
            children: [
              Expanded(
                  flex: flexIn == 0 ? 1 : flexIn,
                  child: Container(color: AppColors.stockIn)),
              Expanded(
                  flex: flexOut == 0 ? 1 : flexOut,
                  child: Container(color: AppColors.stockOut)),
            ],
          );
        }),
      ),
    );
  }
}
