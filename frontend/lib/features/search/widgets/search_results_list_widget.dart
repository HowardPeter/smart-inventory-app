import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart'; // Đa ngôn ngữ

class SearchResultsListWidget extends GetView<TSearchController> {
  const SearchResultsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Đang load
      if (controller.isSearching.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      // 2. Chưa gõ gì -> Hiện Lịch sử tìm kiếm
      if (controller.currentSearchQuery.value.isEmpty) {
        return _buildRecentSearches();
      }

      // 3. Gõ rồi nhưng KHÔNG CÓ KẾT QUẢ
      if (controller.inventoryResults.isEmpty) {
        return _buildNoResults();
      }

      // 4. HIỂN THỊ KẾT QUẢ THẬT
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.inventoryResults.length,
        itemBuilder: (context, index) {
          final inv = controller.inventoryResults[index];
          final pkg = inv.productPackage;

          final name = pkg?.displayName ?? 'Unknown Item';
          final barcode = pkg?.barcodeValue ?? 'No Barcode';
          final qty = inv.quantity;
          final threshold = inv.reorderThreshold;

          // Xử lý logic màu sắc báo động kho
          Color statusColor = AppColors.stockIn; // Xanh (Healthy)
          if (qty == 0) {
            statusColor = AppColors.alertText; // Đỏ (Out of stock)
          } else if (qty <= threshold) {
            statusColor = AppColors.primary; // Vàng (Low stock)
          }

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
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Text("SKU: $barcode",
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subText)),
                    const SizedBox(width: 8),
                    Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            color: AppColors.softGrey, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    // Số lượng hiển thị màu theo tình trạng kho
                    Text(
                      "In Stock: $qty",
                      style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: AppColors.softGrey),
              onTap: () {
                // Tự động lưu lịch sử tìm kiếm khi User bấm vào một kết quả
                controller
                    .saveRecentSearch(controller.currentSearchQuery.value);
                // TODO: Chuyển sang trang Product Detail
              },
            ),
          );
        },
      );
    });
  }

  // --- GIAO DIỆN KHÔNG CÓ KẾT QUẢ ---
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.softGrey),
          const SizedBox(height: 16),
          Text(TTexts.errorNotFoundTitle.tr,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText)),
          const SizedBox(height: 8),
          Text(TTexts.errorNotFoundMessage.tr,
              style: const TextStyle(fontSize: 13, color: AppColors.subText)),
        ],
      ),
    );
  }

  // --- LỊCH SỬ TÌM KIẾM ---
  Widget _buildRecentSearches() {
    if (controller.recentSearches.isEmpty) return const SizedBox.shrink();

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
                onPressed: controller.clearRecentSearches,
                child: const Text("Clear",
                    style: TextStyle(color: AppColors.primary, fontSize: 13)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.recentSearches
                .map((item) => ActionChip(
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                          color: AppColors.softGrey.withOpacity(0.2)),
                      label: Text(item,
                          style: const TextStyle(
                              color: AppColors.primaryText, fontSize: 13)),
                      onPressed: () {
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
