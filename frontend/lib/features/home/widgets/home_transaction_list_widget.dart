import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'home_transaction_item_widget.dart'; // Import Item bên trên

class HomeTransactionListWidget extends StatelessWidget {
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
        HomeTransactionItemWidget(
          icon: Icons.download_rounded,
          iconColor: AppColors.stockIn,
          title: TTexts.homeInboundShipment.tr,
          time: "10:45 AM",
          amount: "+150",
          isPositive: true,
        ),
        HomeTransactionItemWidget(
          icon: Icons.upload_rounded,
          iconColor: AppColors.stockOut,
          title: TTexts.homeOutboundDelivery.tr,
          time: "02:15 PM",
          amount: "-45",
          isPositive: false,
        ),
        HomeTransactionItemWidget(
          icon: Icons.sync_alt_rounded,
          iconColor: AppColors.primary,
          title: TTexts.homeStockAdjustment.tr,
          time: "04:30 PM",
          amount: "-5",
          isPositive: false,
        ),
      ],
    );
  }
}
