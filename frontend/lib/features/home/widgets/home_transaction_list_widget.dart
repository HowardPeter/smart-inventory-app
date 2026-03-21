import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:intl/intl.dart';
import 'home_transaction_item_widget.dart';

class HomeTransactionListWidget extends GetView<HomeController> {
  const HomeTransactionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.homeTodaysTransactions.tr,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: 16),
        Obx(() {
          // code cũ của m nè
          // if (controller.recentTransactions.isEmpty) {
          //   return TEmptyStateWidget(
          //     icon: Icons.receipt_long_outlined,
          //     title: TTexts.emptyTransactionTitle.tr,
          //     subtitle: TTexts.emptyTransactionSubtitle.tr,
          //   );
          // }
// Lắng nghe trực tiếp vào transactions.obs
          if (controller.transactions.isEmpty) {
            return TEmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: TTexts.emptyTransactionTitle.tr,
              subtitle: TTexts.emptyTransactionSubtitle.tr,
            );
          }

          // Sau đó mới dùng getter để lấy 3 item gần nhất để hiển thị
          final recentList = controller.recentTransactions;

          return Column(
            // children: controller.recentTransactions.map((t) {
            children: recentList.map((t) {
              // 1. SỬ DỤNG TRỰC TIẾP THUỘC TÍNH TỪ MODEL
              final type = t.type;
              final date = t.createdAt;
              final formattedTime = DateFormat('hh:mm a').format(date);

              final details = t.details;

              // Tính tổng số lượng từ List<HomeTransactionDetailModel>
              int totalQuantity = 0;
              for (var detail in details) {
                // detail.quantity đã là int từ Model, chỉ cần gọi .abs()
                totalQuantity += detail.quantity.abs();
              }

              IconData icon;
              Color color;
              String title;
              bool isPositive;
              String displayAmount = totalQuantity.toString();

              // 2. LOGIC XUẤT/NHẬP KHO (INVENTORY FLOW)
              if (type == 'sale') {
                icon = Icons.upload_rounded;
                color = AppColors.stockOut;
                title = TTexts.homeOutboundDelivery.tr;
                isPositive = false;
                displayAmount = "-$displayAmount";
              } else if (type == 'refund' || type == 'import') {
                icon = Icons.download_rounded;
                color = AppColors.stockIn;
                title = TTexts.homeInboundShipment.tr;
                isPositive = true;
                displayAmount = "+$displayAmount";
              } else {
                icon = Icons.sync_alt_rounded;
                color = AppColors.primary;
                title = TTexts.homeStockAdjustment.tr;

                // Tính tổng quantity giữ nguyên dấu để biết là điều chỉnh âm hay dương
                int rawQuantitySum = 0;
                for (var detail in details) {
                  rawQuantitySum += detail.quantity;
                }

                isPositive = rawQuantitySum >= 0;
                displayAmount =
                    isPositive ? "+$displayAmount" : "-$displayAmount";
              }

              return HomeTransactionItemWidget(
                icon: icon,
                iconColor: color,
                title: title,
                time: formattedTime,
                amount: displayAmount,
                isPositive: isPositive,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
