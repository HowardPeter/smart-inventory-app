import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';

class HomeDailySummaryWidget extends GetView<HomeController> {
  const HomeDailySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.homeInventoryOverview.tr,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText),
          ),
          const SizedBox(height: 24),
          Obx(() {
            final double stockIn = controller.stockInToday.toDouble();
            final double stockOut = controller.stockOutToday.toDouble();
            final int adjustmentsCount = controller.todayAdjustments.length;

            double maxY = (stockIn > stockOut ? stockIn : stockOut) * 1.3;
            if (maxY == 0) maxY = 10;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =====================================
                // CỘT TRÁI: BIỂU ĐỒ 
                // =====================================
                SizedBox(
                  height: 150,
                  width: 110,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              Colors.transparent, 
                          tooltipMargin: 2,
                          tooltipPadding: EdgeInsets.zero, 
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toInt().toString(),
                              const TextStyle(
                                color: AppColors
                                    .primaryText, 
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                fontFamily: 'Poppins',
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const style = TextStyle(
                                  color: AppColors.subText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold);
                              String text = value == 0 ? 'IN' : 'OUT';
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(text, style: style),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.softGrey.withOpacity(0.15),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          showingTooltipIndicators: [0], // Luôn hiện số
                          barRods: [
                            BarChartRodData(
                              toY: stockIn,
                              color: AppColors.stockIn,
                              width: 26,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          showingTooltipIndicators: [0], // Luôn hiện số
                          barRods: [
                            BarChartRodData(
                              toY: stockOut,
                              color: AppColors.stockOut,
                              width: 26,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // =====================================
                // CỘT PHẢI: CHÚ THÍCH
                // =====================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(TTexts.homeStockIn.tr, AppColors.stockIn,
                          stockIn.toInt().toString()),
                      const SizedBox(height: 12),
                      Divider(
                          color: AppColors.softGrey.withOpacity(0.1),
                          height: 1),
                      const SizedBox(height: 12),
                      _buildLegend(TTexts.homeStockOut.tr, AppColors.stockOut,
                          stockOut.toInt().toString()),
                      const SizedBox(height: 12),
                      Divider(
                          color: AppColors.softGrey.withOpacity(0.1),
                          height: 1),
                      const SizedBox(height: 12),
                      _buildLegend(TTexts.homeStockAdjustment.tr, Colors.orange,
                          "$adjustmentsCount ${TTexts.itemsText.tr.toLowerCase()}"),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegend(String title, Color color, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
