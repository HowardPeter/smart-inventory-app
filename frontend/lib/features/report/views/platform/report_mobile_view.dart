import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/widgets/report/report_date_header_widget.dart';
import 'package:frontend/features/report/widgets/report/report_filter_tabs_widget.dart';
import 'package:frontend/features/report/widgets/report/report_history_header_widget.dart';
import 'package:frontend/features/report/widgets/report/report_transaction_card_widget.dart';

import 'package:get/get.dart';

class ReportMobileView extends GetView<ReportController> {
  const ReportMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER
              ReportHistoryHeaderWidget(),

              SizedBox(height: 20),

              // 2. CHIPS (TABS)
              ReportFilterTabsWidget(),

              SizedBox(height: 24),

              // 3. NGÀY THÁNG ĐỘNG
              ReportDateHeaderWidget(),

              // 🟢 KHOẢNG CÁCH TỪ NGÀY THÁNG XUỐNG CARD
              SizedBox(height: 20),

              // 4. DANH SÁCH CARD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Column(
                  children: [
                    ReportTransactionCardWidget(
                      transactionId: '10548050845408779',
                      dateStr: '3 March 2026',
                      typeDisplay: 'Inventory Adjustment',
                      typeColor: Color(0xFFFF9900),
                      leftBottomLabel: 'Check Items / Stock Stats',
                      itemsDisplay: '8',
                      itemsColor: Color(0xFFFF9900),
                      moneyDisplay: '+179 items',
                      moneyColor: AppColors.stockIn,
                      isInbound: true,
                    ),
                    ReportTransactionCardWidget(
                      transactionId: '10548050845408509',
                      dateStr: '3 March 2026',
                      typeDisplay: 'Outbound',
                      typeColor: AppColors.stockOut,
                      leftBottomLabel: 'Total Items / Transaction',
                      itemsDisplay: '-6',
                      itemsColor: AppColors.stockOut,
                      moneyDisplay: '+292.000 đ',
                      moneyColor: AppColors.stockIn,
                      isOutbound: true,
                    ),
                    ReportTransactionCardWidget(
                      transactionId: '10548050845408504',
                      dateStr: '3 March 2026',
                      typeDisplay: 'Inbound',
                      typeColor: AppColors.stockIn,
                      leftBottomLabel: 'Total Items / Transaction',
                      itemsDisplay: '+12',
                      itemsColor: AppColors.stockIn,
                      moneyDisplay: '-150.000 đ',
                      moneyColor: AppColors.stockOut,
                      isInbound: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.bottomNavSpacer),
            ],
          ),
        ),
      ),
    );
  }
}
