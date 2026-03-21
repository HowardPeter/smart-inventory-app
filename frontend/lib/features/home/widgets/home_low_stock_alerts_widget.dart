import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

// Đổi sang GetView để lắng nghe Controller
class HomeLowStockAlertsWidget extends GetView<HomeController> {
  const HomeLowStockAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Bọc Obx để tự động cập nhật khi kho hàng thay đổi
    return Obx(() {
      final items = controller.lowStockItems;

      // Ẩn hẳn widget nếu không có cảnh báo nào
      if (items.isEmpty) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius24),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TTexts.homeLowStockAlerts.tr,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.toastErrorBg,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12)),
                        child: Text(
                          // Cập nhật số lượng item động
                          '${items.length} ${TTexts.homeItems.tr}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.toastErrorGradientEnd,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // DUYỆT QUA DANH SÁCH CẢNH BÁO
                  // Lấy tối đa 3-4 item để không làm thẻ bị quá dài, phần còn lại xem ở trang chi tiết
                  ...items.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: _buildAlertItem(
                        // Gọi an toàn ?. để tránh lỗi null
                        name: item.productPackage?.displayName ?? 'Unknown',
                        // Tạm gán Category (bạn có thể bổ sung category vào Model sau)
                        category: 'Product',
                        quantityLeft: item.quantity,
                      ),
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // SỬ DỤNG WIDGET CHUNG Ở ĐÂY
            TCustomFadeOverlayWidget(
              text: TTexts.homeTapToViewAll.tr,
              onTap: () {
                // TODO: Xử lý chuyển sang trang danh sách Alert
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAlertItem(
      {required String name,
      required String category,
      required int quantityLeft}) {
    String quantityText = quantityLeft == 0
        ? TTexts.homeOutOfStock.tr // Thêm check nếu = 0 thì báo HẾT HÀNG
        : TTexts.homeOnlyLeft.tr
            .replaceAll('@quantity', quantityLeft.toString());

    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radius16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radius8)),
            child: const Icon(Icons.image_outlined, color: AppColors.softGrey),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primaryText)),
                Text(category,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.subText)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.toastErrorGradientEnd,
                      shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(quantityText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.toastErrorGradientEnd,
                      fontWeight: FontWeight.w500,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
