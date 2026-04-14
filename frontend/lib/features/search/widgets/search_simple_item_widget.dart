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

    final bool isCategory = product != null && product.productId.isEmpty;
    final bool isBaseProduct =
        product != null && product.productId.isNotEmpty && package == null;
    final bool isPackage = package != null;

    IconData leadingIcon = Iconsax.box_copy;
    String title = TTexts.unknownProduct.tr;
    String subtitle = '';

    if (isPackage) {
      leadingIcon = Iconsax.box_copy;
      title = package.displayName;
      subtitle = "${TTexts.barcodeLabel.tr}: ${package.barcodeValue ?? '---'}";
    } else if (isBaseProduct) {
      leadingIcon = Iconsax.box_tick_copy;
      title = product.name;
      subtitle = "${TTexts.brand.tr}: ${product.brand ?? '---'}";
    } else if (isCategory) {
      leadingIcon = Iconsax.folder_2_copy;
      title = product.name;
      subtitle = TTexts.categoryCatalog.tr;
    }

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
        child: Icon(leadingIcon, color: AppColors.softGrey, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.primaryText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.subText),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.softGrey, size: 18),
    );
  }
}
