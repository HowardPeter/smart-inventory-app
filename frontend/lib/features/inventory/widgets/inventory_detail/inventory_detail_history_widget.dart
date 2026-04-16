import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:frontend/features/inventory/models/inventory_history_model.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailHistoryWidget extends GetView<InventoryDetailController> {
  const InventoryDetailHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.inventoryHistory;
      final lastCount = controller.lastCount;
      final currentQty = controller.quantity;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lastCount > 0 || history.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.softGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius8),
                border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle_copy,
                      size: 18, color: AppColors.subText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.subText,
                            fontFamily: 'Poppins'),
                        children: [
                          TextSpan(text: "${TTexts.latestInventoryCount.tr}: "),
                          TextSpan(
                              text: "$lastCount",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText)),
                          TextSpan(text: "  •  ${TTexts.currentQty.tr}: "),
                          TextSpan(
                              text: "$currentQty",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              child: Center(
                child: Text(TTexts.noHistoryAvailable.tr,
                    style: const TextStyle(
                        color: AppColors.subText, fontStyle: FontStyle.italic)),
              ),
            )
          else
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: AppSizes.p20,
                      right: AppSizes.p20,
                      bottom: history.length > 5 ? 60 : AppSizes.p8),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                    itemCount: history.length > 5 ? 5 : history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildHistoryCard(item);
                    },
                  ),
                ),
                if (history.length > 5)
                  TCustomFadeOverlayWidget(
                    text: TTexts.homeTapToViewMoreHistory.tr,
                    onTap: controller.viewAllHistory,
                  ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildHistoryCard(InventoryHistoryModel item) {
    final isOut = item.type == InventoryActionType.stockOut;
    final isAdjust = item.type == InventoryActionType.adjust;

    String displayQty = "";
    Color displayColor = AppColors.primary;

    if (isAdjust) {
      // Nếu là điều chỉnh: dựa vào số âm/dương của qty
      displayQty = item.qty > 0 ? "+${item.qty}" : "${item.qty}";
      displayColor = item.qty > 0
          ? AppColors.stockIn
          : (item.qty < 0 ? AppColors.alertText : AppColors.primary);
    } else if (isOut) {
      // Nếu là xuất kho: luôn hiển thị dấu trừ
      displayQty = "-${item.qty.abs()}";
      displayColor = AppColors.alertText;
    } else {
      // Nếu là nhập kho: luôn hiển thị dấu cộng
      displayQty = "+${item.qty.abs()}";
      displayColor = AppColors.stockIn;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(
          color: isAdjust
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
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
                  : (isOut ? Iconsax.arrow_up_3_copy : Iconsax.arrow_down_copy),
              color: isAdjust
                  ? AppColors.primary
                  : (isOut ? AppColors.alertText : AppColors.stockIn),
              size: 18),
        ),
        title: Text(item.note,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isAdjust ? FontWeight.bold : FontWeight.w600)),
        subtitle: Text(item.date,
            style: const TextStyle(fontSize: 12, color: AppColors.subText)),
        trailing: Text(displayQty,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: displayColor,
                fontFamily: 'Poppins')),
      ),
    );
  }
}
