import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class InventoryInsightShimmerWidget extends StatefulWidget {
  const InventoryInsightShimmerWidget({super.key});

  @override
  State<InventoryInsightShimmerWidget> createState() =>
      _InventoryInsightShimmerWidgetState();
}

class _InventoryInsightShimmerWidgetState
    extends State<InventoryInsightShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5, // Hiển thị 5 cục mờ mờ
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: AppColors.softGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 150,
                          height: 14,
                          color: AppColors.softGrey.withOpacity(0.2)),
                      const SizedBox(height: 8),
                      Container(
                          width: 100,
                          height: 10,
                          color: AppColors.softGrey.withOpacity(0.2)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        width: 60,
                        height: 14,
                        color: AppColors.softGrey.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    Container(
                        width: 40,
                        height: 20,
                        decoration: BoxDecoration(
                            color: AppColors.softGrey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8))),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
