import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ReportShimmerWidget extends StatelessWidget {
  const ReportShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER SHIMMER
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.p16, AppSizes.p24, AppSizes.p16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBox(width: 200, height: 28),
                    const SizedBox(height: 8),
                    _buildBox(width: 150, height: 16),
                  ],
                ),
                Row(
                  children: [
                    _buildBox(width: 48, height: 48, borderRadius: 15),
                    const SizedBox(width: AppSizes.p16),
                    _buildBox(width: 48, height: 48, borderRadius: 15),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. TABS SHIMMER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Row(
              children: [
                _buildBox(width: 90, height: 36, borderRadius: 20),
                const SizedBox(width: 12),
                _buildBox(width: 100, height: 36, borderRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 3. DATE SHIMMER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBox(width: 140, height: 38),
                const SizedBox(height: 8),
                _buildBox(width: 90, height: 22),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. LIST CARDS SHIMMER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.p16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.softGrey.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBox(width: 120, height: 12),
                              const SizedBox(height: 8),
                              _buildBox(width: 160, height: 16),
                            ],
                          ),
                          _buildBox(width: 50, height: 30, borderRadius: 4),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBox(width: 100, height: 12),
                              const SizedBox(height: 8),
                              _buildBox(width: 90, height: 16),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBox(width: 100, height: 12),
                              const SizedBox(height: 8),
                              _buildBox(width: 80, height: 16),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBox(width: 150, height: 12),
                              const SizedBox(height: 8),
                              _buildBox(width: 180, height: 20),
                            ],
                          ),
                          _buildBox(width: 36, height: 36, borderRadius: 18),
                        ],
                      ),
                    ],
                  ),
                ),
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
      double borderRadius = 8}) {
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
