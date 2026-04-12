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
            final double total = stockIn + stockOut;

            return Row(
              children: [
                // =========================================
                // BIỂU ĐỒ DONUT (PIE CHART) Ở BÊN TRÁI
                // =========================================
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(enabled: false),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 42, // Kích thước lỗ tròn ở giữa
                          sections: _showingSections(stockIn, stockOut, total),
                        ),
                      ),
                      // CHỮ TỔNG CỘNG Ở GIỮA
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            total.toInt().toString(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Text(
                            TTexts.homeItems.tr.toLowerCase(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.subText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                // =========================================
                // CHÚ THÍCH (LEGEND) Ở BÊN PHẢI
                // =========================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(TTexts.homeStockIn.tr, AppColors.stockIn,
                          stockIn.toInt()),
                      const SizedBox(height: 16),
                      Divider(
                          color: AppColors.softGrey.withOpacity(0.1),
                          height: 1),
                      const SizedBox(height: 16),
                      _buildLegend(TTexts.homeStockOut.tr, AppColors.stockOut,
                          stockOut.toInt()),
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

  // Hàm chia tỷ lệ cho biểu đồ
  List<PieChartSectionData> _showingSections(
      double stockIn, double stockOut, double total) {
    // Nếu hôm nay chưa có giao dịch nào -> Trả về vòng xám mờ
    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.softGrey.withOpacity(0.15),
          value: 100,
          title: '',
          radius: 12,
        )
      ];
    }

    return [
      PieChartSectionData(
        color: AppColors.stockIn,
        value: stockIn,
        title: '',
        radius: stockIn >= stockOut ? 16 : 12, // Làm dày hơn nếu chiếm đa số
      ),
      PieChartSectionData(
        color: AppColors.stockOut,
        value: stockOut,
        title: '',
        radius: stockOut > stockIn ? 16 : 12,
      ),
    ];
  }

  // Hàm build dòng chú thích
  Widget _buildLegend(String title, Color color, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.subText,
              ),
            ),
          ],
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
