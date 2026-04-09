import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ReportTransactionDetailShimmerWidget extends StatelessWidget {
  final double topOffset;

  const ReportTransactionDetailShimmerWidget(
      {super.key, required this.topOffset});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: topOffset + 24,
        left: AppSizes.p16,
        right: AppSizes.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card Shimmer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildBox(
                            width: 40, height: 40, borderRadius: 20), // Avatar
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBox(width: 100, height: 14),
                            const SizedBox(height: 6),
                            _buildBox(width: 70, height: 10),
                          ],
                        )
                      ],
                    ),
                    _buildBox(
                        width: 60, height: 24, borderRadius: 12), // Status
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.softGrey.withOpacity(0.15)),
                const SizedBox(height: 16),
                _buildBox(width: double.infinity, height: 14),
                const SizedBox(height: 12),
                _buildBox(width: 200, height: 14),
                const SizedBox(height: 12),
                _buildBox(width: 250, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Items Title Shimmer
          _buildBox(width: 140, height: 18),
          const SizedBox(height: 16),

          // Items List Shimmer
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  _buildBox(width: 48, height: 48, borderRadius: 12), // Icon
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBox(width: double.infinity, height: 14),
                        const SizedBox(height: 8),
                        _buildBox(width: 100, height: 10),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBox(width: 60, height: 14),
                            _buildBox(width: 30, height: 14, borderRadius: 4),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(
      {required double width,
      required double height,
      double borderRadius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.softGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
