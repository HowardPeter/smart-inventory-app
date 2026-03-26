import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class InventoryInsightItemWidget extends StatelessWidget {
  final InventoryModel inventory;

  const InventoryInsightItemWidget({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    final pkg = inventory.productPackage;
    final name = pkg?.displayName ?? 'Unknown Product';
    final sku = pkg?.barcodeValue ?? 'N/A';
    final price = pkg?.sellingPrice ?? 0.0;
    final qty = inventory.quantity;
    final threshold = inventory.reorderThreshold;

    Color statusColor = AppColors.stockIn;
    String statusText = "${TTexts.inStock.tr}: $qty";

    if (qty == 0) {
      statusColor = AppColors.alertText;
      statusText = TTexts.tabOutStock.tr;
    } else if (qty <= threshold) {
      statusColor = AppColors.primary;
      statusText = "${TTexts.tabLowStock.tr}: $qty";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20), // Bo góc mềm mại hơn
        // Bỏ viền cứng, thay bằng đổ bóng mờ cực nhạt để nổi khối
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor
                  .withOpacity(0.1), // Đổi màu nền icon theo tình trạng kho
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.inventory_2_outlined, color: statusColor, size: 22),
          ),
          const SizedBox(width: 16),

          // Info Box
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  "SKU: $sku",
                  style:
                      const TextStyle(color: AppColors.subText, fontSize: 12),
                ),
              ],
            ),
          ),

          // Price & Status Box (Đã bỏ nút 3 chấm)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${price.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
