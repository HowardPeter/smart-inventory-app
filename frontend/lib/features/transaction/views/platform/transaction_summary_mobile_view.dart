import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart'; // Import TAppBar
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/transaction_summary_controller.dart';
import 'package:frontend/features/transaction/widgets/transaction_summary/transaction_summary_receipt_card_widget.dart';
import 'package:get/get.dart';

class TransactionSummaryMobileView
    extends GetView<TransactionSummaryController> {
  const TransactionSummaryMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Tính toán khoảng trống an toàn dưới AppBar
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 🟢 KÍCH HOẠT HIỆU ỨNG BLUR CHO APPBAR
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.transactionCompletedTitle.tr,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // Đẩy content xuống dưới AppBar
        padding: EdgeInsets.fromLTRB(
            AppSizes.p24, topOffset + 20, AppSizes.p24, AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟢 HÌNH ẢNH NHỎ LẠI NHƯ YÊU CẦU
            Image.asset(TImages.coreImages.successTransaction,
                width: 160, height: 160),

            const SizedBox(height: 16),

            // 🟢 TEXT SUCCESS MỎNG LẠI (w500 thay vì bold)
            Text(
              TTexts.transactionSuccessTitle.tr,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w500, // Chữ thon gọn hơn
                  color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              TTexts.transactionSuccessSub.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subText, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // THẺ HÓA ĐƠN
            const TransactionSummaryReceiptCardWidget(),

            const SizedBox(height: 24),

            // NÚT XEM CHI TIẾT
            TextButton(
              onPressed: controller.openDetailsBottomSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(TTexts.checkDetails.tr,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_upward_rounded,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: TPrimaryButtonWidget(
            text: TTexts.backToHome.tr,
            customIcon: const Icon(Icons.home_filled, color: Colors.white),
            onPressed: controller.goToHome,
          ),
        ),
      ),
    );
  }
}
