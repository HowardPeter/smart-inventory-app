import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart'; // ĐÃ THÊM IMPORT
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:frontend/features/inventory/widgets/product_catalog_detail/product_catalog_detail_package_item_widget.dart';
import 'package:frontend/features/inventory/widgets/product_catalog_detail/product_catalog_detail_header_widget.dart';

class ProductCatalogDetailMobileView
    extends GetView<ProductCatalogDetailController> {
  const ProductCatalogDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final product = controller.product;
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: TRefreshIndicatorWidget(
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchPackages(isRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            const ProductCatalogDetailHeaderWidget(),

            // THÔNG TIN CƠ BẢN
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p20, vertical: AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${TTexts.brand.tr}: ${product.brand ?? TTexts.na.tr}', // ĐÃ SỬA
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.subText),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                  ],
                ),
              ),
            ),

            // HEADER CỦA DANH SÁCH PACKAGES
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(TTexts.packagesOrVariants.tr, // ĐÃ SỬA
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    if (controller.canManageProduct)
                      TextButton.icon(
                        onPressed: () => controller.addNewPackage(),
                        icon: const Icon(Iconsax.add_circle_copy,
                            size: 18, color: AppColors.primary),
                        label: Text(TTexts.add.tr, // ĐÃ SỬA
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),

            // DANH SÁCH PACKAGES
            Obx(() {
              if (controller.isLoadingPackages.value) {
                return _buildShimmerPackages(); // GỌI HÀM SHIMMER TÁCH RỜI
              }

              if (controller.packages.isEmpty) {
                return SliverToBoxAdapter(
                  child: TEmptyStateWidget(
                    icon: Iconsax.box_remove_copy,
                    title: TTexts.noPackagesFound.tr, // ĐÃ SỬA
                    subtitle: TTexts.addPackageSubtitle.tr, // ĐÃ SỬA
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p20, vertical: 12),
                sliver: SliverList.builder(
                  itemCount: controller.packages.length,
                  itemBuilder: (context, index) {
                    return ProductCatalogDetailPackageItemWidget(
                      package: controller.packages[index],
                      onEdit: () =>
                          controller.editPackage(controller.packages[index]),
                    );
                  },
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  // HÀM TÁCH RỜI ĐỂ HIỂN THỊ SHIMMER CHO GỌN
  Widget _buildShimmerPackages() {
    return SliverPadding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 12),
      sliver: SliverList.builder(
        itemCount: 3, // Khởi tạo 3 khung load giả
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TFormSkeletonWidget(),
        ),
      ),
    );
  }
}
