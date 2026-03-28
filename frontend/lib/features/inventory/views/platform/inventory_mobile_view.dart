import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/layouts/t_barcode_scanner_layout.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:frontend/core/ui/widgets/t_search_bar_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory/inventory_insights_widget.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/inventory/widgets/inventory/inventory_header_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory/inventory_flow_chart_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory/inventory_dynamic_category_widget.dart';

class InventoryMobileView extends GetView<InventoryController> {
  const InventoryMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InventoryHeaderWidget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.p8),
                    TSearchBarWidget(
                      hintText: TTexts.searchItemsPackages.tr,
                      onTap: () {
                        Get.toNamed(AppRoutes.search, arguments: {
                          'target': SearchTarget.inventory,
                          'hint': TTexts.searchItemsPackages.tr,
                        });
                      },
                      onScanTap: () =>
                          Get.to(() => const TBarcodeScannerLayout()),
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // 1. INVENTORY FLOW
                    InventoryFlowChartWidget(),
                    const SizedBox(height: AppSizes.p20),

                    // 2. STOCK INSIGHTS
                    const InventoryInsightsWidget(),
                    const SizedBox(height: AppSizes.p32),

                    // 3. PRODUCT CATALOG
                    const Text(
                      "Product Catalog",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 12),
                    const InventoryDynamicCategoryWidget(),
                    const TBottomNavSpacerWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
