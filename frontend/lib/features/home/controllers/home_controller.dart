import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:frontend/core/models/user_profile_model.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/controllers/user_controller.dart';

class HomeController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return TTexts.goodMorning.tr;
    if (hour < 17) return TTexts.goodAfternoon.tr;
    return TTexts.goodEvening.tr;
  }

  @override
  void onInit() {
    super.onInit();
    loadAllHomeData();
  }

  Future<void> loadAllHomeData() async {
    try {
      isLoading.value = true;
      final String response =
          await rootBundle.loadString('assets/mock_data/home_raw_data.json');
      final data = json.decode(response);
      UserController.instance.currentUser.value =
          UserProfileModel.fromJson(data['user_profile']);
      transactions.value =
          List<Map<String, dynamic>>.from(data['transactions']);
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIC TÍNH TOÁN KHOẢNG CHIA (INTERVAL) CHO 5 MỐC ---
  // Công thức: $Interval = (Max - Min) / 4$
  Map<String, double> _calculateAxisLimits(List<double> values) {
    if (values.isEmpty) return {'min': -1.0, 'max': 4.0, 'interval': 1.25};

    double minVal = values.reduce(min);
    double maxVal = values.reduce(max);

    // Nếu chỉ có số dương, ép min về 0 để biểu đồ trông thuận mắt
    if (minVal > 0) minVal = 0;
    // Nếu chỉ có số âm, ép max về 0
    if (maxVal < 0) maxVal = 0;

    // Tạo khoảng đệm 10% để các điểm không dính sát mép biểu đồ
    double padding = (maxVal - minVal).abs() * 0.1;
    if (padding == 0) padding = 1.0;

    double finalMin = (minVal - padding).floorToDouble();
    double finalMax = (maxVal + padding).ceilToDouble();

    // Chia 4 khoảng để có đúng 5 mốc hiển thị
    double interval = (finalMax - finalMin) / 4;

    return {'min': finalMin, 'max': finalMax, 'interval': interval};
  }

  // --- LINE CHART ---
  List<FlSpot> get lineChartSpots {
    final today = DateTime.now();
    Map<double, double> hourly = {0.0: 0, 4.0: 0, 8.0: 0, 12.0: 0};
    for (var t in transactions) {
      final d = DateTime.parse(t['created_at']);
      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day) {
        final amt =
            (double.tryParse(t['total_price'].toString()) ?? 0.0) / 1000;
        final h = d.hour;
        if (h >= 8 && h < 12) {
          hourly[0.0] = hourly[0.0]! + amt;
        } else if (h >= 12 && h < 16) {
          hourly[4.0] = hourly[4.0]! + amt;
        } else if (h >= 16 && h < 20) {
          hourly[8.0] = hourly[8.0]! + amt;
        } else if (h >= 20) {
          hourly[12.0] = hourly[12.0]! + amt;
        }
      }
    }
    return hourly.entries.map((e) => FlSpot(e.key, e.value)).toList();
  }

  Map<String, double> get lineLimits =>
      _calculateAxisLimits(lineChartSpots.map((s) => s.y).toList());

  // --- BAR CHART ---
  List<double> get weeklyBarData {
    Map<int, double> daily = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var t in transactions) {
      final d = DateTime.parse(t['created_at']);
      daily[d.weekday] = (daily[d.weekday] ?? 0) +
          (double.tryParse(t['total_price'].toString()) ?? 0.0) / 1000;
    }
    return daily.values.toList();
  }

  Map<String, double> get barLimits => _calculateAxisLimits(weeklyBarData);

  // --- DOANH THU & % ---
  double get todayRevenue => _sumRevenueByDate(DateTime.now());
  double get yesterdayRevenue =>
      _sumRevenueByDate(DateTime.now().subtract(const Duration(days: 1)));
  double get todayChangePercent =>
      _calculateChange(todayRevenue, yesterdayRevenue);

  double get thisWeekRevenue => _sumRevenueByWeek(0);
  double get lastWeekRevenue => _sumRevenueByWeek(1);
  double get weekChangePercent =>
      _calculateChange(thisWeekRevenue, lastWeekRevenue);

  double _calculateChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  double _sumRevenueByDate(DateTime date) {
    return transactions.where((t) {
      final tDate = DateTime.parse(t['created_at']);
      return tDate.year == date.year &&
          tDate.month == date.month &&
          tDate.day == date.day;
    }).fold(
        0.0,
        (sum, t) =>
            sum + (double.tryParse(t['total_price'].toString()) ?? 0.0));
  }

  double _sumRevenueByWeek(int weeksAgo) {
    final now = DateTime.now();
    final start =
        now.subtract(Duration(days: now.weekday - 1 + (weeksAgo * 7)));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
    return transactions.where((t) {
      final tDate = DateTime.parse(t['created_at']);
      return tDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          tDate.isBefore(end);
    }).fold(
        0.0,
        (sum, t) =>
            sum + (double.tryParse(t['total_price'].toString()) ?? 0.0));
  }
}
