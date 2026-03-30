import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:frontend/features/inventory/widgets/inventory_insight/inventory_insight_item_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';

class InventoryInsightListWidget extends GetView<InventoryInsightController> {
  const InventoryInsightListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nút xóa bộ lọc (Clear Filters)
        Obx(() {
          final isFiltered = controller.activeFilter.value != TTexts.tabAll ||
              controller.activeCategory.value != TTexts.allItems;

          if (!isFiltered) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  controller.activeFilter.value = TTexts.tabAll;
                  controller.activeCategory.value = TTexts.allItems;
                  controller.refreshData();
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  TTexts.clearFilters.tr,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),

        Obx(() {
          // 1. Nếu đang tải lần đầu và danh sách trống -> Shimmer
          // Lưu ý: Chỉ hiện Shimmer của List, không hiện Shimmer của toàn trang để tránh lồng nhau
          if (controller.isLoading.value && controller.displayList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Vẽ nhanh vài cái khung xương giả thay vì gọi nguyên file Shimmer to
                  _SimpleListSkeleton(),
                  _SimpleListSkeleton(),
                  _SimpleListSkeleton(),
                ],
              ),
            );
          }

          final list = controller.displayList;

          // 2. Không có dữ liệu sau khi lọc
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: TEmptyStateWidget(
                icon: Iconsax.box_search_copy,
                title: TTexts.noDataAvailable.tr,
                subtitle: TTexts.emptyFilterMessage.tr,
              ),
            );
          }

          // 3. Có dữ liệu
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Quan trọng vì nằm trong CustomScrollView
            itemCount: list.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == list.length) {
                // Loading cho Infinite Scroll (Load More)
                return controller.isLoadingMore.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: TAnimationLoaderWidget(
                            text: TTexts.loadingProduct.tr,
                            showBackground: false,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              return InventoryInsightItemWidget(displayItem: list[index]);
            },
          );
        }),
      ],
    );
  }
}

// Widget phụ vẽ khung xương đơn giản cho List để tránh lỗi lồng ScrollView
class _SimpleListSkeleton extends StatelessWidget {
  const _SimpleListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
