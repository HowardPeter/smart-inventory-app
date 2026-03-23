import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:intl/intl.dart';

class HomeInventoryLegendWidget extends GetView<HomeController> {
  const HomeInventoryLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,##0');

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLegendItem(
              color: AppColors.stockIn,
              label: TTexts.homeStockIn.tr,
              value: format.format(controller.stockInToday)),
          _buildLegendItem(
              color: AppColors.stockOut,
              label: TTexts.homeStockOut.tr,
              value: format.format(controller.stockOutToday)),
        ],
      );
    });
  }

  Widget _buildLegendItem(
      {required Color color, required String label, required String value}) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 14, color: AppColors.subText)),
        Text(value,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}
