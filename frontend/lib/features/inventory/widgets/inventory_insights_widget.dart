import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

import 'inventory_health_widget.dart';
import 'inventory_distribution_widget.dart';

class InventoryInsightsWidget extends StatelessWidget {
  const InventoryInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        border: Border.all(
            color: AppColors.stockIn.withOpacity(0.3)), // Viền nhận diện
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ĐỒNG BỘ "Details >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Stock Health",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              InkWell(
                onTap: () {},
                child: const Row(
                  children: [
                    Text("Details",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary, size: 18),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: AppSizes.p16),

          // GỌI COMPONENT 1: HEALTH
          const InventoryHealthWidget(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.black12, height: 1),
          ),

          // GỌI COMPONENT 2: DISTRIBUTION
          const InventoryDistributionWidget(),
        ],
      ),
    );
  }
}
