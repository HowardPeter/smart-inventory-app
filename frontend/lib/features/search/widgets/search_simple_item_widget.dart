import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SearchSimpleItemWidget extends StatelessWidget {
  final InventoryInsightDisplayModel displayItem;
  final VoidCallback onTap;

  const SearchSimpleItemWidget({
    super.key,
    required this.displayItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final package = displayItem.inventory.productPackage;
    final product = displayItem.product;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.softGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            const Icon(Iconsax.box_copy, color: AppColors.softGrey, size: 22),
      ),
      title: Text(
        package?.displayName ?? product?.name ?? TTexts.unknownProduct.tr,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.primaryText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "${TTexts.barcodeLabel.tr}: ${package?.barcodeValue ?? '---'}",
        style: const TextStyle(fontSize: 12, color: AppColors.subText),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.softGrey, size: 18),
    );
  }
}
