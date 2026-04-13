import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/home/widgets/home_header_widget.dart';
import 'package:frontend/features/home/widgets/home_quick_actions_widget.dart';
import 'package:frontend/features/home/widgets/home_revenue_chart_widget.dart';
import 'package:frontend/features/home/widgets/home_daily_summary_widget.dart';
import 'package:frontend/features/home/widgets/home_adjustment_stats_widget.dart'; // ĐÃ IMPORT
import 'package:frontend/features/home/widgets/home_low_stock_alerts_widget.dart';
import 'package:frontend/features/home/widgets/home_transaction_list_widget.dart';

class HomeMobileScreen extends GetView<HomeController> {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.p32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CHÀO HỎI & THÔNG BÁO
                const HomeHeaderWidget(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. DOANH THU HÔM NAY (ĐẨY LÊN TRÊN CÙNG)
                      const SizedBox(height: AppSizes.p8),
                      const HomeRevenueChartWidget(),
                      const SizedBox(
                          height: AppSizes.p32), // Tăng khoảng cách cho thoáng

                      // 3. QUICK ACTIONS (NẰM DƯỚI DOANH THU)
                      const HomeQuickActionsWidget(),
                      const SizedBox(height: AppSizes.p32),

                      // 4. BÁO CÁO KHO TRONG NGÀY (Nhập/Xuất)
                      Text(
                        TTexts.homeDailyOverview.tr,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      const HomeDailySummaryWidget(),
                      const SizedBox(height: AppSizes.p24),

                      // ==========================================
                      // BỔ SUNG LỊCH SỬ KIỂM KHO VÀO ĐÚNG VỊ TRÍ
                      // ==========================================
                      Obx(() => controller.todayAdjustments.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: AppSizes.p24),
                              child: HomeAdjustmentStatsWidget(),
                            )
                          : const SizedBox.shrink()),

                      // 5. CẢNH BÁO KHO
                      Obx(() => controller.lowStockItems.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: AppSizes.p24),
                              child: HomeLowStockAlertsWidget(),
                            )
                          : const SizedBox.shrink()),

                      // 6. GIAO DỊCH GẦN NHẤT
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius24),
                        ),
                        child: Stack(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(AppSizes.p20),
                              child: Column(
                                children: [
                                  HomeTransactionListWidget(),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                            TCustomFadeOverlayWidget(
                              text: TTexts.homeTapToViewMoreHistory.tr,
                              onTap: () {
                                // TODO: Chuyển sang Lịch sử giao dịch
                              },
                            ),
                          ],
                        ),
                      ),

                      const TBottomNavSpacerWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
