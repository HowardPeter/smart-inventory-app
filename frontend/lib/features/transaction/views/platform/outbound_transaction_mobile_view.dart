import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_search_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/features/transaction/widgets/outbound_transaction/outbound_transaction_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/outbound_transaction/outbound_transaction_export_type_selector_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_cart_item_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_empty_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class OutboundTransactionMobileView
    extends GetView<OutboundTransactionController> {
  const OutboundTransactionMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          controller.handleExit();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: TAppBarWidget(
            title: TTexts.outboundTransactionTitle.tr,
            showBackArrow: true,
            centerTitle: true,
            onBackPress: controller.handleExit,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: TSearchBarWidget(
                  hintText: TTexts.searchProductToAdd.tr,
                  onTap: () => Get.toNamed(AppRoutes.search,
                      arguments: {'target': SearchTarget.transactions}),
                  onScanTap: () => controller.openScanner(),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.cartItems.isEmpty) {
                    return const TransactionEmptyWidget();
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p20),
                        itemCount: controller.cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = controller.cartItems[index];
                          return TransactionCartItemWidget(
                            item: item,
                            onIncrease: () => controller.updateQuantity(
                                index, item.quantity + 1),
                            onDecrease: () => controller.updateQuantity(
                                index, item.quantity - 1),
                          );
                        },
                      ),
                      _buildReasonAndNoteSection(),
                    ],
                  );
                }),
              ),
            ],
          ),
          bottomNavigationBar: const OutboundTransactionBottomBarWidget(),
        ));
  }

  Widget _buildReasonAndNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
              EdgeInsets.fromLTRB(AppSizes.p20, AppSizes.p24, AppSizes.p20, 16),
          child: Divider(color: AppColors.divider),
        ),

        // 🟢 WIDGET CHỌN LÝ DO
        Obx(() => OutboundTransactionExportTypeSelectorWidget(
              reasons: controller.predefinedReasons,
              selectedReason: controller.selectedReason.value,
              onReasonSelected: controller.selectReason,
              // Truyền biến kiểu int
              otherFinancialEffect: controller.otherFinancialEffect.value,
              onOtherFinancialEffectChanged: (val) =>
                  controller.otherFinancialEffect.value = val,
            )),

        const SizedBox(height: 8),

        // 🟢 WIDGET GHI CHÚ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          child: TTextFormFieldWidget(
            label: TTexts.noteLabel.tr,
            controller: controller.noteController,
            hintText: TTexts.noteHint.tr,
            maxLines: 3,
            prefixIcon: Icons.edit_note_rounded,
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
