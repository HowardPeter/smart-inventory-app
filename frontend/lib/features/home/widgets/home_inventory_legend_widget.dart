import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HomeInventoryLegendWidget extends StatelessWidget {
  const HomeInventoryLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem(
            color: AppColors.stockIn,
            label: TTexts.homeStockIn.tr,
            value: '245'),
        _buildLegendItem(
            color: AppColors.stockOut,
            label: TTexts.homeStockOut.tr,
            value: '198'),
      ],
    );
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
