import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class InventorySearchBarWidget extends StatelessWidget {
  const InventorySearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/search'),
      child: Container(
        height: 54, // Chiều cao chuẩn
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          boxShadow: [
            BoxShadow(
              color: AppColors.softGrey.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        // SỬ DỤNG STACK ĐỂ PHẦN TRẮNG ĐÈ LÊN PHẦN CAM
        child: Stack(
          children: [
            // 1. LỚP NỀN (BOTTOM): Gradient cam trải dài 100%, chứa nút Scan ở góc phải
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.primary, AppColors.secondPrimary],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              alignment: Alignment.centerRight,
              child: const SizedBox(
                width: 54,
                child: Center(
                  child: Icon(Iconsax.scan_barcode_copy,
                      color: Colors.white, size: 24),
                ),
              ),
            ),

            // 2. LỚP TRÊN (TOP): Phần nền trắng nhập text
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background, // Trắng
                  // Bí quyết: Bo cả 4 góc. Góc phải sẽ tạo ra đường cong lẹm vào nền cam!
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: AppSizes.p16),
                    Icon(Iconsax.search_normal_copy,
                        color: AppColors.softGrey, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Search by name, SKU...",
                        style:
                            TextStyle(color: AppColors.softGrey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                        width: 8), // Khoảng cách nhỏ trước khi hết viền trắng
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
