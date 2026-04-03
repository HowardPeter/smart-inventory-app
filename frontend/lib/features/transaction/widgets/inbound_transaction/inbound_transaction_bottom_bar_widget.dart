import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';

class InboundTransactionBottomBarWidget
    extends GetView<InboundTransactionController> {
  const InboundTransactionBottomBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TTexts.totalFunds.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(() => Text('\$${controller.totalFunds.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary))),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => TPrimaryButtonWidget(
                  text: TTexts.completeImport.tr,
                  onPressed: controller.cartItems.isEmpty
                      ? null
                      : () => controller.completeImport(),
                  backgroundColor: controller.cartItems.isEmpty
                      ? AppColors.softGrey
                      : AppColors.primary,
                )),
          ],
        ),
      ),
    );
  }
}
