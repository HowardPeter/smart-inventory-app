import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InventoryDetailPricingWidget extends GetView<InventoryDetailController> {
  const InventoryDetailPricingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: Row(
        children: [
          Expanded(
              child: _buildPricingCol("Import Cost", controller.importPrice,
                  AppColors.primaryText)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
              child: _buildPricingCol(
                  "Sale Price", controller.price, AppColors.primary)),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(child: _buildMarginCol(controller.profitMargin)),
        ],
      ),
    );
  }

  Widget _buildPricingCol(String title, double price, Color color) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12, color: AppColors.subText)),
        const SizedBox(height: 4),
        Text("\$${price.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildMarginCol(double margin) {
    final color = margin > 0
        ? AppColors.stockIn
        : (margin < 0 ? AppColors.alertText : AppColors.subText);
    return Column(
      children: [
        const Text("Profit Margin",
            style: TextStyle(fontSize: 12, color: AppColors.subText)),
        const SizedBox(height: 4),
        Text(
            margin > 0
                ? "+${margin.toStringAsFixed(1)}%"
                : "${margin.toStringAsFixed(1)}%",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins')),
      ],
    );
  }
}
