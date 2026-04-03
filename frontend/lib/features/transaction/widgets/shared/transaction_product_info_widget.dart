import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/controllers/transaction_item_add_controller.dart';

class TransactionProductInfoWidget extends GetView<TransactionItemAddController> {
  const TransactionProductInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: Column(
        children: [
          // Bọc Obx cho phần text vì nó có thể đổi khi API ngầm gọi xong (thay đổi displayName/barcode của package)
          Obx(() => Text(
                controller.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.primaryText, 
                    height: 1.3),
              )),
          const SizedBox(height: AppSizes.p8),
          
          Obx(() => Text(
                "${TTexts.barcodeLabel.tr}: ${controller.barcode}",
                style: const TextStyle(
                    fontSize: 14, 
                    color: AppColors.subText, 
                    fontWeight: FontWeight.w500),
              )),
          const SizedBox(height: AppSizes.p12),

          // Bọc Obx cho Chips vì màu sắc và số lượng tồn kho sẽ thay đổi
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // 1. Category Chip
                _buildChip(controller.categoryName),
                
                // 2. Health Status Chip
                _buildChip(
                  '${controller.healthStatusText} (${controller.currentStock})',
                  textColor: controller.healthStatusColor,
                  bgColor: controller.healthStatusColor.withOpacity(0.1),
                  hasBorder: false,
                ),
                
                // 3. Brand Chip
                if (controller.brandName != 'No Brand' && controller.brandName.isNotEmpty)
                  _buildChip(controller.brandName),
                  
                // 4. Inactive Chip
                if (!controller.isProductActive)
                  _buildChip('Inactive'),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Hàm helper để code gọn hơn
  Widget _buildChip(String label, {Color? textColor, Color? bgColor, bool hasBorder = true}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12, 
          fontWeight: hasBorder ? FontWeight.w600 : FontWeight.w700, 
          color: textColor ?? AppColors.primaryText,
        ),
      ),
      backgroundColor: bgColor ?? AppColors.surface,
      side: hasBorder ? const BorderSide(color: AppColors.divider) : BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }
}