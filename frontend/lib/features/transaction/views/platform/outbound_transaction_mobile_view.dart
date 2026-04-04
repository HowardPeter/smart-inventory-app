import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_search_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/features/transaction/widgets/outbound_transaction/outbound_transaction_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_cart_item_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_empty_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class OutboundTransactionMobileView
    extends GetView<OutboundTransactionController> {
  const OutboundTransactionMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: TTexts.outboundTransactionTitle.tr,
        showBackArrow: true,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: TSearchBarWidget(
              hintText: TTexts.searchProductToAdd.tr,
              onTap: () => Get.toNamed(AppRoutes.search,
                  arguments: {'target': SearchTarget.transactions}),
              onScanTap: () => controller.openScanner(),
            ),
          ),

          // 2. DANH SÁCH GIỎ HÀNG
          Expanded(
            child: Obx(() {
              if (controller.cartItems.isEmpty) {
                return const TransactionEmptyWidget();
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p20, vertical: 8),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return TransactionCartItemWidget(
                    item: controller.cartItems[index],
                    onIncrease: () => controller.updateQuantity(
                        index, controller.cartItems[index].quantity + 1),
                    onDecrease: () => controller.updateQuantity(
                        index, controller.cartItems[index].quantity - 1),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const OutboundTransactionBottomBarWidget(),
    );
  }
}
