import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';

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
        return _buildRecentSearches();
      }

      // --- MOCK KẾT QUẢ TÌM KIẾM DẠNG CARD ---
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.softGrey.withOpacity(0.1)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary),
              ),
              title: Text(
                "${controller.currentSearchQuery.value} Item ${index + 1}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text("SKU: PKG-001 • In Stock: 45",
                  style: TextStyle(fontSize: 12, color: AppColors.subText)),
              trailing:
                  const Icon(Icons.chevron_right, color: AppColors.softGrey),
              onTap: () {
                // TODO: Chuyển sang trang chi tiết
              },
            ),
          );
        },
      );
    });
  }

  // --- LỊCH SỬ TÌM KIẾM ---
  Widget _buildRecentSearches() {
    final recentList = ["Keyboard", "Wireless Mouse", "Monitor", "Cables"];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Searches",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {},
                child: const Text("Clear",
                    style: TextStyle(color: AppColors.primary, fontSize: 13)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentList
                .map((item) => ActionChip(
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                          color: AppColors.softGrey.withOpacity(0.2)),
                      label: Text(item,
                          style: const TextStyle(
                              color: AppColors.primaryText, fontSize: 13)),
                      onPressed: () {
                        // Tự động điền text và kích hoạt tìm kiếm khi bấm vào chip
                        controller.textController.text = item;
                        controller.onSearchChanged(item);
                      },
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
