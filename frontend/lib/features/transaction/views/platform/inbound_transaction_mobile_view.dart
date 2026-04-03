import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_search_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/transaction/widgets/inbound_transaction/inbound_transaction_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/inbound_transaction/inbound_transaction_cart_item_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_empty_widget.dart';
import 'package:frontend/routes/app_routes.dart'; // THÊM IMPORT NÀY
import 'package:frontend/features/search/controllers/search_controller.dart'; // THÊM IMPORT NÀY
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class InboundTransactionMobileView
    extends GetView<InboundTransactionController> {
  const InboundTransactionMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: TTexts.inboundTransaction.tr,
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
              // ĐÃ SỬA: Điều hướng thẳng sang Màn hình Search của bạn
              onTap: () => Get.toNamed(AppRoutes.search,
                  arguments: {'target': SearchTarget.transactions}),
              // Quét mã vạch thì vẫn dùng hàm openScanner
              onScanTap: () => controller.openScanner(),
            ),
          ),

          // 2. DANH SÁCH GIỎ HÀNG (Sản phẩm chuẩn bị nhập)
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
                  return InboundTransactionCartItemWidget(
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
      // 3. THANH TỔNG TIỀN BOTTOM BAR
      bottomNavigationBar: const InboundTransactionBottomBarWidget(),
    );
  }
}
