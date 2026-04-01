import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_form_skeleton_widget.dart';
import 'package:shimmer/shimmer.dart';

class InventoryDetailShimmerWidget extends StatelessWidget {
  const InventoryDetailShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:
          AppColors.surface, // Tận dụng màu surface bạn dùng trong skeleton
      highlightColor: AppColors.white.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Giả lập Header/Ảnh sản phẩm
            Container(
              width: double.infinity,
              height: 250,
              color: AppColors.surface,
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Dùng TFormSkeleton cho phần thông tin chi tiết
                  // Giả lập các dòng: Tên, Brand, Giá, v.v.
                  const TFormSkeletonWidget(itemCount: 4),

                  const SizedBox(height: AppSizes.p24),

                  // 3. Giả lập phần Inventory Stats (Ô vuông)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // 4. Giả lập phần biểu đồ/lịch sử
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
