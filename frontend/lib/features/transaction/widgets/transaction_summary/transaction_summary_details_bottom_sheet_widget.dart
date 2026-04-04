import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/transaction_summary_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionSummaryDetailsBottomSheetWidget
    extends GetView<TransactionSummaryController> {
  const TransactionSummaryDetailsBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 KHÔNG CẦN SafeArea, Container bo góc, hay Drag handle nữa
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thông tin chung (Đã bỏ Padding horizontal vì Widget chung lo rồi)
        _buildInfoRow(TTexts.transactionNumber.tr,
            controller.transaction.transactionId ?? TTexts.na.tr),
        const SizedBox(height: 8),
        _buildInfoRow(TTexts.transactionDate.tr, controller.dateStr),

        const SizedBox(height: 16),

        // Danh sách sản phẩm (Bỏ Flexible, chuyển physics thành NeverScrollable)
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // 🟢 Để cha tự cuộn
          padding: EdgeInsets.zero,
          itemCount: controller.transaction.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.transaction.items[index];
            return Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Iconsax.box_1_copy,
                      size: 20, color: AppColors.subText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.packageInfo?.displayName ?? TTexts.product.tr,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText)),
                      Text('${TTexts.qty.tr}: ${item.quantity}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.subText)),
                    ],
                  ),
                ),
                Text('\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            );
          },
        ),

        // PHẦN HIỂN THỊ NOTE
        if (controller.transaction.note != null &&
            controller.transaction.note!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 18, color: AppColors.subText),
                  const SizedBox(width: 4),
                  Text(TTexts.noteLabel.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.subText)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                controller.transaction.note!,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryText,
                    height: 1.4),
              ),
            ],
          ),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),

        // Tổng tiền
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(TTexts.total.tr.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.subText)),
            Text('\$${controller.rawTotal.abs().toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 18)),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: TPrimaryButtonWidget(
            text: TTexts.goBack.tr,
            backgroundColor: AppColors.primary,
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.subText)),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText)),
      ],
    );
  }
}
