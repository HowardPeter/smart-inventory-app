import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/widgets/report/report_calendar_widget.dart';
import 'package:frontend/features/report/widgets/report/report_date_header_widget.dart';
import 'package:frontend/features/report/widgets/report/report_filter_tabs_widget.dart';
import 'package:frontend/features/report/widgets/report/report_history_header_widget.dart';
import 'package:frontend/features/report/widgets/report/report_shimmer_widget.dart';
import 'package:frontend/features/report/widgets/report/report_transaction_card_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReportMobileView extends GetView<ReportController> {
  const ReportMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: TRefreshIndicatorWidget(
          onRefresh: () => controller.fetchMockData(),
          child: Obx(() {
            if (controller.isLoading.value) return const ReportShimmerWidget();

            final displayList = controller.filteredTransactions;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReportHistoryHeaderWidget(),
                  const SizedBox(height: 20),
                  const ReportFilterTabsWidget(),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topLeft,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: controller.activeTab.value == 'Today'
                        ? const ReportDateHeaderWidget(
                            key: ValueKey('date_header'))
                        : const ReportCalendarWidget(
                            key: ValueKey('calendar_widget')),
                  ),
                  const SizedBox(height: 24),
                  if (displayList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: TEmptyStateWidget(
                        icon: Iconsax.document_text_1_copy,
                        title: 'No Transactions',
                        subtitle:
                            'There are no activities recorded for this date.',
                      ),
                    )
                  else
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                      child: Column(
                        children: displayList.map((tx) {
                          // Tương tự logic UI cũ của bạn
                          Color typeColor = AppColors.primaryText;
                          Color moneyColor = AppColors.primaryText;
                          Color itemsColor = AppColors.primaryText;
                          String bottomLabel = 'Total Items / Transaction';

                          if (tx.type == 'INBOUND') {
                            typeColor = AppColors.stockIn;
                            itemsColor = AppColors.stockIn;
                            moneyColor = AppColors.stockOut;
                          } else if (tx.type == 'OUTBOUND') {
                            typeColor = AppColors.stockOut;
                            itemsColor = AppColors.stockOut;
                            moneyColor = AppColors.stockIn;
                          } else {
                            typeColor = const Color(0xFFFF9900);
                            itemsColor = const Color(0xFFFF9900);
                            moneyColor = AppColors.stockIn;
                            bottomLabel = 'Check Items / Stock Stats';
                          }

                          return ReportTransactionCardWidget(
                            transactionId: tx.transactionId ?? 'N/A',
                            dateStr: tx.createdAt != null
                                ? '${tx.createdAt!.day}/${tx.createdAt!.month}/${tx.createdAt!.year}'
                                : 'N/A',
                            typeDisplay: tx.type,
                            typeColor: typeColor,
                            leftBottomLabel: bottomLabel,
                            itemsDisplay: '0', // Fake items count
                            itemsColor: itemsColor,
                            moneyDisplay: '${tx.totalPrice} đ',
                            moneyColor: moneyColor,
                            isInbound: tx.type == 'INBOUND',
                            isOutbound: tx.type == 'OUTBOUND',
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: AppSizes.bottomNavSpacer),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
