import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailHistoryWidget extends GetView<InventoryDetailController> {
  const InventoryDetailHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p20, vertical: AppSizes.p8),
      itemCount: controller.inventoryHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = controller.inventoryHistory[index];
        final isOut = item['type'] == 'OUT';
        final isAdjust = item['type'] == 'ADJUST'; // Thẻ Kiểm kho

        return Container(
          decoration: BoxDecoration(
            // SỬA: Bỏ màu nền chói, đưa về màu surface bình thường cho thanh lịch
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            border: Border.all(
              // SỬA: Viền màu mờ nhẹ nhàng hơn, độ dày 1.0 đồng bộ với các thẻ khác
              color: isAdjust
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.divider.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isAdjust
                      ? AppColors.primary.withOpacity(0.1)
                      : (isOut
                          ? AppColors.toastWarningBg
                          : AppColors.toastSuccessBg),
                  shape: BoxShape.circle),
              child: Icon(
                  isAdjust
                      ? Iconsax.clipboard_tick_copy
                      : (isOut
                          ? Iconsax.arrow_up_3_copy
                          : Iconsax.arrow_down_copy),
                  color: isAdjust
                      ? AppColors.primary
                      : (isOut ? AppColors.alertText : AppColors.stockIn),
                  size: 18),
            ),
            title: Text(item['note'],
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isAdjust ? FontWeight.bold : FontWeight.w600)),
            subtitle: Text(item['date'],
                style: const TextStyle(fontSize: 12, color: AppColors.subText)),
            trailing: Text(
                // SỬA: Bỏ chữ (Actual), nếu là Adjust thì chỉ hiện số trần (hoặc dùng dấu = đằng trước cho rõ nghĩa)
                isAdjust
                    ? "${item['qty']}"
                    : (isOut ? "${item['qty']}" : "+${item['qty']}"),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAdjust
                        ? AppColors.primary
                        : (isOut ? AppColors.alertText : AppColors.stockIn),
                    fontFamily: 'Poppins')),
          ),
        );
      },
    );
  }
}
