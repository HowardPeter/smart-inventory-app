import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/home/widgets/home_header_widget.dart';
import 'package:frontend/features/home/widgets/home_revenue_chart_widget.dart';
import 'package:frontend/features/home/widgets/home_inventory_overview_widget.dart';
import 'package:frontend/features/home/widgets/home_quick_actions_widget.dart';
import 'package:frontend/features/home/widgets/home_low_stock_alerts_widget.dart';

class HomeMobileScreen extends GetView<HomeController> {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: AppSizes.p32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeaderWidget(), // Đã nhận greetingText từ controller

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  child: Column(
                    children: [
                      SizedBox(height: AppSizes.p16),
                      HomeRevenueChartWidget(),
                      SizedBox(height: AppSizes.p24),
                      HomeInventoryOverviewWidget(),
                      SizedBox(height: AppSizes.p24),
                      HomeQuickActionsWidget(),
                      SizedBox(height: AppSizes.p24),
                      HomeLowStockAlertsWidget(),
                      TBottomNavSpacer(),
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
