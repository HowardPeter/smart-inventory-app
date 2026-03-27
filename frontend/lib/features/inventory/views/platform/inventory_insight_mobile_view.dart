import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:frontend/features/inventory/widgets/inventory_insight/inventory_insight_category_chip_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_insight/inventory_insight_list_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_insight/inventory_insight_overview_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_expandable_fab_widget.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';

class InventoryInsightMobileView extends GetView<InventoryInsightController> {
  const InventoryInsightMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.inventoryList.tr,
        showSearchIcon: true,
      ),
      floatingActionButton: TExpandableFabWidget(
        onManualAdd: () {},
        onScanAdd: () => Get.to(() => const TBarcodeScannerLayout()),
      ),
      body: TRefreshIndicatorWidget(
        onRefresh: controller.refreshData,
        edgeOffset: topOffset,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: topOffset + 16),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TTexts.totalInventory.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          "${controller.getCount(TTexts.tabAll)} ${TTexts.items.tr}",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: AppColors.primaryText,
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.p16),
            ),
            const SliverToBoxAdapter(
              child: InventoryInsightOverviewWidget(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.p16),
            ),
            const SliverToBoxAdapter(
              child: InventoryInsightCategoryChipWidget(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.p8),
            ),
            const SliverToBoxAdapter(
              child: InventoryInsightListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
