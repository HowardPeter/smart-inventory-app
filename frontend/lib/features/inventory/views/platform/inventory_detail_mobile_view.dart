// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_header_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_health_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_product_info_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_barcode_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_pricing_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_history_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_related_packages_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_bottom_action_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_basic_info_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_stock_stats_widget.dart';

class InventoryDetailMobileView extends GetView<InventoryDetailController> {
  const InventoryDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryDetailController>(
      builder: (ctrl) {
        return PopScope(
          canPop: ctrl.historyStack.isEmpty,
          onPopInvoked: (didPop) {
            if (!didPop) ctrl.goBack();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,

              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation);

                final fade = Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation);

                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: child,
                  ),
                );
              },

              /// 🔥 KEY = trigger animation
              child: _DetailContent(
                key: ValueKey(ctrl.barcode),
              ),
            ),
            bottomNavigationBar: const InventoryDetailBottomActionWidget(),
          ),
        );
      },
    );
  }
}

//
// =============
// CONTENT 
// =============
//
class _DetailContent extends StatelessWidget {
  const _DetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const InventoryDetailHeaderWidget(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSizes.p12,
              bottom: AppSizes.p24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InventoryDetailProductInfoWidget(),
                const SizedBox(height: AppSizes.p16),
                InventoryDetailBarcodeWidget(),
                const _Divider(),
                InventoryDetailPricingWidget(),
                const _Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: Text(
                    "Inventory Status",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Expanded(
                        flex: 4,
                        child: InventoryDetailHealthWidget(),
                      ),
                      const SizedBox(width: AppSizes.p20),
                      Expanded(
                        flex: 5,
                        child: InventoryDetailBasicInfoWidget(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: InventoryDetailStockStatsWidget(),
                ),
                const _Divider(),
                _buildSectionTitle("Related Packages"),
                InventoryDetailRelatedPackagesWidget(),
                const _Divider(),
                _buildSectionTitle("Inventory History"),
                InventoryDetailHistoryWidget(),
                const SizedBox(height: AppSizes.bottomNavSpacer),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p20,
        vertical: 4,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.p16,
        horizontal: AppSizes.p20,
      ),
      child: Divider(
        color: AppColors.divider.withOpacity(0.6),
        height: 1,
      ),
    );
  }
}
