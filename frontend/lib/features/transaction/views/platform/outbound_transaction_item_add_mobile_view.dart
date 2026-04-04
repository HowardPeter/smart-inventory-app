import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_item_add_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_header_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_product_info_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_batch_selector_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class OutboundTransactionItemAddMobileView
    extends GetView<OutboundTransactionItemAddController> {
  const OutboundTransactionItemAddMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final importPrice = controller
            .initialItem.inventory.productPackage?.importPrice
            .toStringAsFixed(2) ??
        "0.00";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          TransactionHeaderWidget(
              imageUrl: controller.initialItem.product?.imageUrl),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.p24),
                  const TransactionProductInfoWidget(),
                  const _Divider(),

                  // 🟢 UI CHỌN NHIỀU LÔ HÀNG (Y HỆT FIGMA)
                  Obx(() => TransactionBatchSelectorWidget(
                        inboundTransactions:
                            controller.availableInboundTxs.toList(),
                        selectedBatchesQty:
                            Map.from(controller.selectedBatchesQty),
                        onUpdateQty: controller.updateBatchQty,
                        currentPackageId:
                            controller.initialItem.inventory.productPackageId,
                      )),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TTextFormFieldWidget(
                          label: TTexts.sellingPriceLot.tr,
                          hintText: '0.00',
                          controller: controller.priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefixIcon: Iconsax.money_send_copy,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Iconsax.info_circle_copy,
                                size: 14, color: AppColors.softGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${TTexts.importPriceLot.tr}: \$$importPrice',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.softGrey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const _Divider(),

                  // 🟢 HIỂN THỊ TỔNG SỐ LƯỢNG LẤY TỪ CÁC LÔ VÀ TỔNG TIỀN
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(TTexts.totalQuantity.tr,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: AppColors.subText)),
                            Obx(() => Text('${controller.totalQuantity}',
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subText))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(TTexts.subtotal.tr,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText)),
                            Obx(() => Text(
                                '\$${controller.totalPrice.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.p20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 15, offset: Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Obx(() => TPrimaryButtonWidget(
                text: TTexts.addToTransaction.tr,
                // Nếu chưa chọn số lượng nào thì mờ nút đi
                backgroundColor: controller.totalQuantity > 0
                    ? AppColors.primary
                    : AppColors.softGrey.withOpacity(0.5),
                onPressed: controller.totalQuantity > 0
                    ? () => controller.confirmAndAddToCart()
                    : () {},
              )),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.p16, horizontal: AppSizes.p20),
      child: Divider(color: AppColors.divider.withOpacity(0.6), height: 1),
    );
  }
}
