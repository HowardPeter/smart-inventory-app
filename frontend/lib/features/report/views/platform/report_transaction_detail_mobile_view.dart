import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart'; // 🟢 Thêm import Snackbar
import 'package:frontend/features/report/controllers/report_transaction_detail_controller.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_info_card_widget.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_item_card_widget.dart';
import 'package:frontend/features/report/widgets/report_transaction_detail/report_transaction_detail_shimmer_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; // 🟢 Thêm import Icon
import 'package:intl/intl.dart';

class ReportTransactionDetailView
    extends GetView<ReportTransactionDetailController> {
  const ReportTransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tính toán bù trừ cho AppBar kính mờ
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,

      // --- APPBAR VỚI HIỆU ỨNG BLUR VÀ NÚT EXPORT ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.white.withOpacity(0.65),
              child: SafeArea(
                bottom: false,
                child: TAppBarWidget(
                  title: 'Transaction Detail',
                  showBackArrow: true,
                  // 🟢 BỔ SUNG NÚT EXPORT Ở GÓC PHẢI
                  actions: [
                    IconButton(
                      onPressed: () {
                        // Logic xuất dữ liệu của riêng giao dịch này
                        if (controller.transaction.value != null) {
                          final txId =
                              controller.transaction.value!.transactionId;
                          // Tạm thời show Snackbar thông báo, sau này ráp API Export vào đây
                          TSnackbarsWidget.success(
                            title: 'Export Successful',
                            message:
                                'Transaction $txId data has been exported.',
                          );
                        }
                      },
                      icon: const Icon(
                        Iconsax.document_download_copy,
                        color: AppColors
                            .primaryText, // Cùng màu với Title cho đồng bộ
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // --- NỘI DUNG CHÍNH ---
      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchTransactionDetail(),
        child: Obx(() {
          // 1. TRẠNG THÁI LOADING
          if (controller.isLoading.value) {
            return ReportTransactionDetailShimmerWidget(topOffset: topOffset);
          }

          final tx = controller.transaction.value;
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          // 2. TRẠNG THÁI HIỂN THỊ DATA
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: EdgeInsets.only(
              top: topOffset + 24,
              left: AppSizes.p16,
              right: AppSizes.p16,
              bottom: 120, // Khoảng trống cho Panel dưới đáy
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportTransactionDetailInfoCardWidget(tx: tx),
                const SizedBox(height: 32),

                const Text(
                  'Transaction Items',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
                const SizedBox(height: 16),

                // Rải danh sách Items thẳng vào Column
                ...tx.items.map((item) =>
                    ReportTransactionDetailItemCardWidget(item: item)),
              ],
            ),
          );
        }),
      ),

      // --- PANEL TỔNG TIỀN DƯỚI ĐÁY ---
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.transaction.value == null)
          return const SizedBox.shrink();

        final tx = controller.transaction.value!;
        final moneyFormatted =
            NumberFormat.currency(locale: 'en_US', symbol: '\$')
                .format(tx.totalPrice);
        final totalQty = tx.items.fold(0, (sum, item) => sum + item.quantity);

        return Container(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.p24, AppSizes.p20, AppSizes.p24, AppSizes.p32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryText.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Items',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('$totalQty',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(moneyFormatted,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
