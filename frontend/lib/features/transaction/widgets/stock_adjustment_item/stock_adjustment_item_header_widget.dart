import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StockAdjustmentItemHeaderWidget extends StatelessWidget {
  final AdjustmentItemRx item;

  const StockAdjustmentItemHeaderWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(TTexts.productInformation.tr,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText)),
            Text("${TTexts.currentStock.tr}: ${item.systemQty}",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subText)),
          ],
        ),
        const SizedBox(height: 12),
        // CARD SẢN PHẨM RIÊNG BIỆT
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Iconsax.box_1_copy, color: AppColors.subText),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primaryText)),
                    const SizedBox(height: 4),
                    Text(
                        "${TTexts.barcode.tr}: ${item.packageInfo?.barcodeValue ?? 'N/A'}",
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subText)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
