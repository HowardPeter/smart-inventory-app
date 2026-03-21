import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeRevenueLineChartWidget extends StatefulWidget {
  const HomeRevenueLineChartWidget({super.key});

  @override
  State<HomeRevenueLineChartWidget> createState() =>
      _HomeRevenueLineChartWidgetState();
}

class _HomeRevenueLineChartWidgetState extends State<HomeRevenueLineChartWidget>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<HomeController>();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final limits = controller.lineLimits;
      final spots = controller.lineChartSpots;

      if (spots.length < 2) return const SizedBox();

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          final progress = _animationController.value;

          final animatedSpots = _buildSegmentSpots(spots, progress);

          return LineChart(
            LineChartData(
              minX: spots.first.x,
              maxX: spots.last.x,
              minY: limits['min'],
              maxY: limits['max'],

              // TOOLTIP
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primary,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                    return LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}k\$',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // GRID
              gridData: FlGridData(
                show: true,
                horizontalInterval: limits['interval'],
                drawVerticalLine: false,
              ),

              // TITLES
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: limits['interval'],
                    reservedSize: 45,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toStringAsFixed(1)}k\$',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 4,
                    reservedSize: 25,
                    getTitlesWidget: _bottomTitles,
                  ),
                ),
              ),

              borderData: FlBorderData(show: false),

              // LINE
              lineBarsData: [
                LineChartBarData(
                  spots: animatedSpots,
                  isCurved: false, // giữ đoạn thẳng rõ ràng
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),

            // 🔥 QUAN TRỌNG: tắt animation của fl_chart
            duration: Duration.zero,
          );
        },
      );
    });
  }

  // 🔥 CORE LOGIC: vẽ từng đoạn
  List<FlSpot> _buildSegmentSpots(List<FlSpot> spots, double progress) {
    final totalSegments = spots.length - 1;
    final segmentProgress = progress * totalSegments;

    List<FlSpot> result = [];

    for (int i = 0; i < totalSegments; i++) {
      final start = spots[i];
      final end = spots[i + 1];

      if (segmentProgress >= i + 1) {
        // đoạn đã xong
        result.add(start);
      } else if (segmentProgress >= i) {
        // đoạn đang vẽ
        final t = segmentProgress - i;

        final easedT = Curves.easeInOut.transform(t);

        final x = start.x + (end.x - start.x) * easedT;
        final y = start.y + (end.y - start.y) * easedT;

        result.add(start);
        result.add(FlSpot(x, y));
        break;
      } else {
        break;
      }
    }

    // 🔥 đảm bảo full khi xong
    if (progress == 1) {
      return List.from(spots);
    }

    return result;
  }

  Widget _bottomTitles(double val, TitleMeta meta) {
    final labels = {0.0: '08:00', 4.0: '12:00', 8.0: '16:00', 12.0: '20:00'};

    if (!labels.containsKey(val)) return const SizedBox();

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: Text(
        labels[val]!,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}
