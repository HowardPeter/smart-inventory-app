import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_item_add_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_header_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_product_info_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_quantity_selector_widget.dart';
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20, vertical: 8),
                    child: Text(TTexts.details.tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20, vertical: 8),
                    child: TransactionQuantitySelectorWidget(
                      controller: controller.quantityController,
                      onIncrease: controller.incrementQuantity,
                      onDecrease: controller.decrementQuantity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p20, vertical: 8),
                    child: TTextFormFieldWidget(
                      label: TTexts.sellingPriceLot.tr,
                      hintText: '0.00',
                      controller: controller.priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Iconsax.money_send_copy,
                    ),
                  ),
                  const _Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                    child: Row(
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
                backgroundColor: controller.itemQuantity.value > 0
                    ? AppColors.primary
                    : AppColors.softGrey.withOpacity(0.5),
                onPressed: controller.itemQuantity.value > 0
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p16, horizontal: AppSizes.p20),
        child: Divider(color: AppColors.divider.withOpacity(0.6), height: 1),
      );
}
