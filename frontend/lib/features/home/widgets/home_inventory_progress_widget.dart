import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HomeInventoryProgressWidget extends StatelessWidget {
  const HomeInventoryProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(flex: 65, child: Container(color: AppColors.stockIn)),
            Expanded(flex: 35, child: Container(color: AppColors.stockOut)),
          ],
        ),
      ),
    );
  }
}
