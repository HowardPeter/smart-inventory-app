import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart'; // THÊM IMPORT NÀY
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailStockStatsWidget
    extends GetView<InventoryDetailController> {
  const InventoryDetailStockStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. HEADER & NÚT TOGGLE ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(TTexts.stockMovement.tr, // FIX: Đa ngôn ngữ
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText)),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider)),
              child: Obx(() => Row(
                    children: [
                      _buildToggleBtn(
                          TTexts.data.tr, // FIX: Đa ngôn ngữ
                          Iconsax.data_copy,
                          !controller.isChartMode.value,
                          () => controller.toggleStatsMode(false)),
                      _buildToggleBtn(
                          TTexts.chart.tr, // FIX: Đa ngôn ngữ
                          Iconsax.chart_2_copy,
                          controller.isChartMode.value,
                          () => controller.toggleStatsMode(true)),
                    ],
                  )),
            )
          ],
        ),
        const SizedBox(height: AppSizes.p16),

        // --- 2. KHU VỰC HIỂN THỊ (DATA HOẶC CHART) ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Obx(() => controller.isChartMode.value
              ? _buildChartView()
              : _buildDataView()),
        ),
      ],
    );
  }

  // --- NÚT BẤM TOGGLE ---
  Widget _buildToggleBtn(
      String label, IconData icon, bool isActive, VoidCallback onTap) {
    // ... Giữ nguyên code _buildToggleBtn
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: isActive ? AppColors.primaryText : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon,
                size: 14, color: isActive ? Colors.white : AppColors.subText),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.subText)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CHẾ ĐỘ 1: VIEW SỐ LIỆU (DATA)
  // ==========================================
  Widget _buildDataView() {
    return Row(
      children: [
        // TODO: Kết nối API lấy tổng lượng nhập/xuất trong khoảng thời gian nhất định (vd: 7 ngày qua)
        Expanded(
            child: _buildDataCard(TTexts.totalStockInTitle.tr,
                "${controller.totalStockIn}", true)),
        const SizedBox(width: AppSizes.p12),
        Expanded(
            child: _buildDataCard(TTexts.totalStockOutTitle.tr,
                "${controller.totalStockOut}", false)),
      ],
    );
  }

  Widget _buildDataCard(String title, String value, bool isStockIn) {
    // ... Giữ nguyên code _buildDataCard
    final color = isStockIn ? AppColors.stockIn : AppColors.alertText;
    final bgColor = isStockIn ? AppColors.toastSuccessBg : AppColors.alertBg;
    final icon = isStockIn ? Iconsax.arrow_down_copy : Iconsax.arrow_up_3_copy;

    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  // ==========================================
  // CHẾ ĐỘ 2: VIEW BIỂU ĐỒ ĐƯỜNG (LINE CHART)
  // ==========================================
  Widget _buildChartView() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(
        children: [
          // Chú thích (Legend)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(
                  TTexts.stockIn.tr, AppColors.stockIn), // FIX: Đa ngôn ngữ
              const SizedBox(width: 16),
              _buildLegendItem(
                  TTexts.stockOut.tr, AppColors.alertText), // FIX: Đa ngôn ngữ
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    data: controller
                        .stockMovementData, // TODO: Cung cấp API model chuẩn cho CustomPainter
                    colorIn: AppColors.stockIn,
                    colorOut: AppColors.alertText,
                    animationValue: value,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Trục X (Các ngày trong tuần)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // TODO: Dịch các thứ trong tuần (Mon, Tue...) hoặc map label từ API trả về
            children: controller.stockMovementData.map((d) {
              return Text(d['day'],
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.subText,
                      fontWeight: FontWeight.w600));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    // ... Giữ nguyên code _buildLegendItem
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.subText,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Lớp _LineChartPainter giữ nguyên, không cần sửa đổi text vì đây là vẽ canvas
class _LineChartPainter extends CustomPainter {
  // ... (Giữ nguyên toàn bộ logic vẽ Line Chart siêu xịn của bạn) ...
  final List<Map<String, dynamic>> data;
  final Color colorIn;
  final Color colorOut;
  final double animationValue;

  _LineChartPainter({
    required this.data,
    required this.colorIn,
    required this.colorOut,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    int maxVal = data.fold<int>(
        0, (m, e) => math.max(m, math.max(e['in'] as int, e['out'] as int)));
    if (maxVal == 0) maxVal = 1;

    final gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.4)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final stepX = size.width / (data.length - 1);

    final paintIn = Paint()
      ..color = colorIn
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintOut = Paint()
      ..color = colorOut
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathIn = Path();
    final pathOut = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final yIn =
          size.height - (data[i]['in'] / maxVal * size.height * animationValue);
      final yOut = size.height -
          (data[i]['out'] / maxVal * size.height * animationValue);

      if (i == 0) {
        pathIn.moveTo(x, yIn);
        pathOut.moveTo(x, yOut);
      } else {
        final prevX = (i - 1) * stepX;
        final prevYIn = size.height -
            (data[i - 1]['in'] / maxVal * size.height * animationValue);
        final prevYOut = size.height -
            (data[i - 1]['out'] / maxVal * size.height * animationValue);

        final controlX = prevX + (x - prevX) / 2;

        pathIn.cubicTo(controlX, prevYIn, controlX, yIn, x, yIn);
        pathOut.cubicTo(controlX, prevYOut, controlX, yOut, x, yOut);
      }
    }

    canvas.drawPath(pathIn, paintIn);
    canvas.drawPath(pathOut, paintOut);

    final dotPaintIn = Paint()
      ..color = colorIn
      ..style = PaintingStyle.fill;
    final dotPaintOut = Paint()
      ..color = colorOut
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final yIn =
          size.height - (data[i]['in'] / maxVal * size.height * animationValue);
      final yOut = size.height -
          (data[i]['out'] / maxVal * size.height * animationValue);

      canvas.drawCircle(Offset(x, yIn), 5, whitePaint);
      canvas.drawCircle(Offset(x, yIn), 3, dotPaintIn);

      canvas.drawCircle(Offset(x, yOut), 5, whitePaint);
      canvas.drawCircle(Offset(x, yOut), 3, dotPaintOut);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
