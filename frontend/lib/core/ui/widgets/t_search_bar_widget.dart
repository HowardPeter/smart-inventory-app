import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TSearchBarWidget extends StatelessWidget {
  final String hintText; // Chuyển thành Dynamic
  final VoidCallback onTap;
  final VoidCallback onScanTap;

  const TSearchBarWidget({
    super.key,
    required this.hintText,
    required this.onTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
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
        child: Stack(
          children: [
            // 1. LỚP NỀN: Nút Scan (Đã fix Gradient đậm đà)
            Container(
              decoration: BoxDecoration(
                // Đổi thành gradient đậm, không dùng secondPrimary nếu nó quá nhạt
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary
                        .withOpacity(0.8), // Đảm bảo màu cam đậm và rực
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                    onTap: onScanTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 15.0),
                      child: Icon(Iconsax.scan_barcode_copy,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),

            // 2. LỚP TRÊN: Phần nhập Text
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: AppSizes.p16),
                    const Icon(Iconsax.search_normal_copy,
                        color: AppColors.softGrey, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hintText, // DATA TRUYỀN VÀO ĐỘNG Ở ĐÂY
                        style: const TextStyle(
                            color: AppColors.softGrey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
