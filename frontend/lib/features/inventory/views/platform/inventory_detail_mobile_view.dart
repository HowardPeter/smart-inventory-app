// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
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
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailMobileView extends GetView<InventoryDetailController> {
  const InventoryDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryDetailController>(
      builder: (ctrl) {
        // Biến check xem có dữ liệu để hiển thị giao diện chính hay chưa
        final hasData =
            !ctrl.isLoading.value && ctrl.currentDisplayItem.value != null;

        return PopScope(
          canPop: ctrl.historyStack.isEmpty,
          onPopInvoked: (didPop) {
            if (!didPop) ctrl.goBack();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,

            // THÊM APPBAR DỰ PHÒNG CHỐNG KẸT MÀN HÌNH
            appBar: hasData
                ? null // Có data thì ẩn đi để nhường đất diễn cho SliverAppBar
                : AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Iconsax.arrow_left_2_copy,
                          color: AppColors.primaryText),
                      onPressed: () => Get.back(),
                    ),
                  ),

            body: ctrl.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : (!hasData
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.box_remove_copy,
                                size: 48, color: AppColors.subText),
                            const SizedBox(height: 16),
                            Text(TTexts.errorNotFoundMessage.tr,
                                style:
                                    const TextStyle(color: AppColors.subText)),
                          ],
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                                  begin: const Offset(1, 0), end: Offset.zero)
                              .animate(animation);
                          final fade = Tween<double>(begin: 0, end: 1)
                              .animate(animation);
                          return SlideTransition(
                            position: slide,
                            child: FadeTransition(opacity: fade, child: child),
                          );
                        },
                        child: _DetailContent(key: ValueKey(ctrl.barcode)),
                      )),

            bottomNavigationBar:
                hasData ? const InventoryDetailBottomActionWidget() : null,
          ),
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        InventoryDetailHeaderWidget(), // Không dùng const
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: Text(
                    TTexts.inventoryStatus.tr,
                    style: const TextStyle(
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
                      Expanded(flex: 4, child: InventoryDetailHealthWidget()),
                      const SizedBox(width: AppSizes.p20),
                      Expanded(
                          flex: 5, child: InventoryDetailBasicInfoWidget()),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: InventoryDetailStockStatsWidget(),
                ),
                const _Divider(),
                _buildSectionTitle(TTexts.relatedPackages.tr),
                InventoryDetailRelatedPackagesWidget(),
                const _Divider(),
                _buildSectionTitle(TTexts.inventoryHistory.tr),
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
