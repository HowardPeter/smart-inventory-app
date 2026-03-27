import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailBottomActionWidget
    extends GetView<InventoryDetailController> {
  const InventoryDetailBottomActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.canManageInventory) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(AppSizes.p20, AppSizes.p16, AppSizes.p20,
          AppSizes.p16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: AppColors.background, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: ElevatedButton(
        onPressed: () => Get.snackbar("Info", "Add to Transaction coming soon"),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16)),
            elevation: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.add_square_copy, color: Colors.white, size: 20),
            const SizedBox(width: AppSizes.p8),
            Text(TTexts.addToTransaction.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
