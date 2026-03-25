import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class InventoryHeaderWidget extends StatelessWidget {
  const InventoryHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.p16, AppSizes.p24, AppSizes.p16, AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Hub',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22, // ĐÃ ĐỔI VỀ 22 THẬT GỌN GÀNG
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage products & stock levels',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.subText),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondPrimary],
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Iconsax.add_square_copy,
                  color: Colors.white, size: 22),
              onPressed: () {/* TODO: Add Product */},
            ),
          ),
        ],
      ),
    );
  }
}
