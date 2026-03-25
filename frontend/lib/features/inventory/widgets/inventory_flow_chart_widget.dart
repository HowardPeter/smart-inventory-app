import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

class InventoryFlowChartWidget extends GetView<InventoryController> {
  InventoryFlowChartWidget({super.key}) {
    // Kích hoạt hiệu ứng mọc lên sau 150ms
    Future.delayed(const Duration(milliseconds: 150), () {
      _isAnimated.value = true;
    });
  }

  final RxBool _isAnimated = false.obs;
  final List<double> _zeros = List.filled(7, 0.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Inventory Flow",
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
          const SizedBox(height: 4),
          const Text("Inbound vs Outbound (7 Days)",
              style: TextStyle(color: AppColors.subText, fontSize: 12)),
          const SizedBox(height: AppSizes.p24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: _buildBarChart(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => _buildBottomStat(
                  "Total Items",
                  "${controller.totalActiveProducts.value}",
                  AppColors.primaryText)),
              // ĐÃ THAY BẰNG DỮ LIỆU TỪ CONTROLLER
              Obx(() => _buildBottomStat("Inbound",
                  "+${controller.weeklyInbound.value}", AppColors.stockIn)),
              Obx(() => _buildBottomStat("Outbound",
                  "-${controller.weeklyOutbound.value}", AppColors.stockOut)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.subText,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  Widget _buildBarChart() {
    return Obx(() {
      // ĐÃ LẤY DỮ LIỆU TỪ CONTROLLER
      final currentInbound =
          _isAnimated.value ? controller.inboundFlow : _zeros;
      final currentOutbound =
          _isAnimated.value ? controller.outboundFlow : _zeros;

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY:
              60, // Tạm fix cứng maxY là 60, sau này bạn có thể tính max tự động trong Controller
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt()],
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.softGrey,
                            fontWeight: FontWeight.w600)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text("${value.toInt()}",
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.softGrey));
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.softGrey.withOpacity(0.1), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: currentInbound.asMap().entries.map((e) {
            int index = e.key;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                    toY: currentInbound[index],
                    color: AppColors.stockIn,
                    width: 6,
                    borderRadius: BorderRadius.circular(2)),
                BarChartRodData(
                    toY: currentOutbound[index],
                    color: AppColors.stockOut,
                    width: 6,
                    borderRadius: BorderRadius.circular(2)),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 1200),
        swapAnimationCurve: Curves.easeOutCubic,
      );
    });
  }
}
