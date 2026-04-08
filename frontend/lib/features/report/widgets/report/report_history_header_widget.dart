import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/widgets/report/report_export_bottom_sheet_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class ReportHistoryHeaderWidget extends StatelessWidget {
  const ReportHistoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final reportCtrl = Get.find<ReportController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.p16, AppSizes.p24, AppSizes.p16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaction History',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText)),
                SizedBox(height: 2),
                Text('Track your store activities',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.subText)),
              ],
            ),
          ),

          // NÚT SEARCH ĐÃ ĐƯỢC KẾT NỐI
          IconButton(
            onPressed: () {
              // Chuyển sang trang Search, truyền argument để đổi Hint Text
              // Sau này có API, bạn chỉ cần vào TSearchController check target là xong
              Get.toNamed(
                AppRoutes.search,
                arguments: {
                  'target': SearchTarget.transactions,
                  'hint': 'Search by ID, note, or type...',
                },
              );
            },
            icon: const Icon(Iconsax.search_normal_1_copy,
                color: AppColors.primary, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSizes.p16),

          // --- NÚT EXPORT GRADIENT ---
          InkWell(
            onTap: () {
              final currentList = reportCtrl.filteredTransactions;

              if (currentList.isEmpty) {
                TSnackbarsWidget.error(
                  title: 'Export Failed',
                  message:
                      'Không có giao dịch nào trong ngày này để xuất báo cáo.',
                );
                return;
              }

              final String dateStr = reportCtrl.activeTab.value == 'Today'
                  ? 'Today'
                  : DateFormat('dd/MM/yyyy')
                      .format(reportCtrl.selectedDay.value);

              TBottomSheetWidget.show(
                child: ReportExportBottomSheetWidget(
                  transactions: currentList,
                  dateStr: dateStr,
                ),
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondPrimary],
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Iconsax.document_download_copy,
                  color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
