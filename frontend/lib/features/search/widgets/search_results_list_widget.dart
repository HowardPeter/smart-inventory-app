import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/search/widgets/search_history_widget.dart';
import 'package:frontend/features/search/widgets/search_simple_item_widget.dart';

class SearchResultsListWidget extends GetView<TSearchController> {
  const SearchResultsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (controller.currentSearchQuery.value.isEmpty) {
        return const SingleChildScrollView(child: SearchHistoryWidget());
      }

      return Column(
        children: [
          // --- THANH GỢI Ý (DID YOU MEAN) CỰC ĐẸP ---
          if (controller.suggestion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: InkWell(
                onTap: controller.applySuggestion,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      // Icon ngôi sao lấp lánh hoặc bóng đèn
                      const Icon(Iconsax.magic_star_copy,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),

                      // Dòng chữ gợi ý đa ngôn ngữ
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: '${TTexts.didYouMean.tr} ',
                            style: const TextStyle(
                                color: AppColors.primaryText, fontSize: 14),
                            children: [
                              TextSpan(
                                text: '"${controller.suggestion.value}"',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const TextSpan(
                                text: ' ?',
                                style: TextStyle(
                                    color: AppColors.primaryText, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Mũi tên chỉ hướng để user biết có thể bấm vào
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.primary.withOpacity(0.7), size: 14),
                    ],
                  ),
                ),
              ),
            ),

          // --- DANH SÁCH KẾT QUẢ HOẶC EMPTY STATE ---
          Expanded(
            child: controller.searchResults.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TEmptyStateWidget(
                      icon: Iconsax.box_search_copy,
                      title: TTexts.noResultsFound.tr,
                      subtitle: TTexts.errorNotFoundMessage.tr,
                    ),
                  )
                : ListView.separated(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: controller.searchResults.length + 1,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 20,
                      color: AppColors.surface,
                    ),
                    itemBuilder: (context, index) {
                      if (index == controller.searchResults.length) {
                        return controller.isLoadingMore.value
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    Center(child: CircularProgressIndicator()))
                            : const SizedBox(height: 80);
                      }

                      final displayItem = controller.searchResults[index];

                      return SearchSimpleItemWidget(
                        displayItem: displayItem,
                        onTap: () => controller.handleItemTap(displayItem),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
