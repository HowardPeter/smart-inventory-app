import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:frontend/features/inventory/widgets/inventory_insight/inventory_insight_item_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_insight/inventory_insight_shimmer_widget.dart';
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
        Obx(() => controller.activeFilter.value != TTexts.tabAll ||
                controller.activeCategory.value != TTexts.allItems
            ? Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      controller.activeFilter.value = TTexts.tabAll;
                      controller.activeCategory.value = TTexts.allItems;
                      controller.refreshData();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(TTexts.clearFilters.tr,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()),
        Obx(() {
          // 1. Đang tải lần đầu
          if (controller.isLoading.value && controller.displayList.isEmpty) {
            return const InventoryInsightShimmerWidget();
          }

          final list = controller.displayList;

          // 2. Không có dữ liệu
          if (list.isEmpty) {
            return TEmptyStateWidget(
              icon: Iconsax.box_search_copy,
              title: TTexts.noDataAvailable.tr,
              subtitle: TTexts.emptyFilterMessage.tr,
            );
          }

          // 3. Có dữ liệu (Cộng thêm 1 item ảo dưới cùng để chứa vòng xoay Loading)
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Obx(() => controller.isLoadingMore.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                            child: TAnimationLoaderWidget(
                          text: TTexts.loadingProduct.tr,
                          showBackground: false,
                        )),
                      )
                    : const SizedBox.shrink());
              }

              // Các hàng bình thường
              return InventoryInsightItemWidget(displayItem: list[index]);
            },
          );
        }),
      ],
    );
  }
}
