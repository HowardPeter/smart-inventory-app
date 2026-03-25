import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

class InventoryDistributionWidget extends GetView<InventoryController> {
  const InventoryDistributionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final distributionData = controller.topDistribution; // DÙNG DATA TỪ API

      if (distributionData.isEmpty) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No data available",
                    style: TextStyle(color: AppColors.softGrey))));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Categories by Volume",
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.subText,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...distributionData.map((item) {
            final double percentage =
                item.value / item.max; // DÙNG MODEL VỪA TẠO
            final bool isTop = item == distributionData.first;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                      width: 75,
                      child: Text(item.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                            height: 10,
                            decoration: BoxDecoration(
                                color: AppColors.softGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5))),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: percentage),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, child) {
                            return FractionallySizedBox(
                              widthFactor: val,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isTop
                                      ? Colors.blue.shade600
                                      : Colors.blue.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                      width: 40,
                      child: Text("${item.value}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subText,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right)),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}
