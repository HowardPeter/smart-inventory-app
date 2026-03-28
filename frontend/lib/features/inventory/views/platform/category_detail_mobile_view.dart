import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/features/inventory/widgets/category_detail/category_detail_product_item_widget.dart';
import 'package:frontend/features/inventory/widgets/category_detail/category_detail_add_product_widget.dart'; // Import widget thêm SP

class CategoryDetailMobileView extends GetView<CategoryDetailController> {
  const CategoryDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: controller.category.name,
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        edgeOffset: topOffset,
        onRefresh: () => controller.fetchProducts(isRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topOffset + 16)),

            // 1. HEADER: Thông tin Category
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p20, vertical: AppSizes.p8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.category.name,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.category.description ??
                          'No description available.',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.subText),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // 2. MAIN CONTENT
            Obx(() {
              if (controller.isLoading.value) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  sliver: SliverList.builder(
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.p12),
                      child: TFormSkeletonWidget(),
                    ),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  // NÚT THÊM SẢN PHẨM MỚI (CHỈ MANAGER THẤY)
                  if (controller.canManageProduct)
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      sliver: SliverToBoxAdapter(
                        child: CategoryDetailAddProductWidget(
                          onTap: () => controller.addNewProduct(),
                        ),
                      ),
                    ),

                  // TRẠNG THÁI TRỐNG SẢN PHẨM
                  if (controller.products.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: TEmptyStateWidget(
                        icon: Iconsax.box_remove_copy,
                        title: 'No Products Found',
                        subtitle:
                            'There are currently no products assigned to this category.',
                      ),
                    )

                  // DANH SÁCH SẢN PHẨM
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      sliver: SliverList.builder(
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          final product = controller.products[index];
                          return CategoryDetailProductItemWidget(
                            product: product,
                            onTap: () => controller.goToProductDetail(product),
                          );
                        },
                      ),
                    ),
                ],
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
