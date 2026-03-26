import 'package:flutter/material.dart';
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
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(TTexts.clearFilters.tr, // ĐÃ DÙNG TTEXTS
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
          // 1. NẾU ĐANG LOAD API -> HIỂN THỊ SHIMMER
          if (controller.isLoading.value) {
            return const InventoryInsightShimmerWidget();
          }

          // ĐÃ SỬA: Dùng displayList thay vì filteredInventories
          final list = controller.displayList;

          // 2. NẾU RỖNG -> HIỂN THỊ EMPTY STATE
          if (list.isEmpty) {
            return TEmptyStateWidget(
              icon: Iconsax.box_search_copy,
              title: TTexts.noDataAvailable.tr,
              subtitle: TTexts.emptyFilterMessage.tr, // ĐÃ DÙNG TTEXTS
            );
          }

          // 3. NẾU CÓ DATA -> HIỂN THỊ LIST THẬT
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              // ĐÃ SỬA: Truyền displayItem thay vì inventory
              return InventoryInsightItemWidget(displayItem: list[index]);
            },
          );
        }),
      ],
    );
  }
}
