import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailRelatedPackagesWidget
    extends GetView<InventoryDetailController> {
  const InventoryDetailRelatedPackagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final related = controller.relatedPackages;

    if (related.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
        child: Text("No other packages available for this product.",
            style: TextStyle(
                color: AppColors.subText,
                fontSize: 13,
                fontStyle: FontStyle.italic)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p20, vertical: AppSizes.p8),
      itemCount: related.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = related[index];
        final pkg = item.inventory.productPackage;
        final name = pkg?.displayName ?? 'Unknown Package';
        final barcode =
            pkg?.barcodeValue ?? 'N/A'; // Hiển thị Barcode đúng ý bạn
        final stock = item.inventory.quantity;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: ListTile(
            // ==========================================
            // THÊM SỰ KIỆN CLICK ĐỂ CHUYỂN TRANG
            // ==========================================
            onTap: () => controller.pushRelatedItem(item),

            // Khai báo shape để khi bấm vào, hiệu ứng sóng (ripple) bo góc chuẩn 16px
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16, vertical: 4),

            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02), blurRadius: 4)
                  ]),
              child: const Icon(Iconsax.box_add_copy,
                  color: AppColors.primaryText, size: 20),
            ),
            title: Text(name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text("Barcode: $barcode",
                style: const TextStyle(fontSize: 12, color: AppColors.subText)),
            trailing: Text("$stock left",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
