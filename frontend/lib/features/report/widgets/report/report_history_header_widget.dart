import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReportHistoryHeaderWidget extends StatelessWidget {
  const ReportHistoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding bottom = 0 để dễ kiểm soát khoảng cách với thẻ tab bên dưới
      padding: const EdgeInsets.fromLTRB(
          AppSizes.p16, AppSizes.p24, AppSizes.p16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction History',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your store activities',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),

          // Nút Search
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.search_normal_1_copy,
                color: AppColors.primary, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSizes.p16),

          // Nút Export (ĐÃ TRẢ VỀ GRADIENT THEO Ý BẠN)
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                // 🟢 Dùng Gradient đồng bộ với hệ thống AppColors
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondPrimary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Iconsax.document_download_copy,
                  color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
