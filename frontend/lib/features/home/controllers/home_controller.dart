// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:frontend/features/home/providers/home_provider.dart'; // ĐÃ THÊM PROVIDER
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart'; // ĐÃ ĐỔI SANG MODEL THẬT
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';

class HomeController extends GetxController {
  final HomeProvider _provider = HomeProvider(); // Khởi tạo Provider

  final RxBool isLoading = true.obs;

  // Dùng thẳng Model chuẩn của hệ thống
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<InventoryModel> lowStockItems = <InventoryModel>[].obs;
  final RxInt totalStockQuantity = 0.obs;

  var userProfile = Rxn<UserProfileModel>();
  final UserProfileProvider userProfileProvider = UserProfileProvider();
  final notificationController = Get.find<NotificationController>();
  RxInt unreadCount = 0.obs;

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
    getMyProfile();

    ever(notificationController.unreadCount, (int count) {
      unreadCount.value = count;
    });
    unreadCount.value = notificationController.unreadCount.value;
  }

  Future<void> getMyProfile() async {
    try {
      final profile = await userProfileProvider.fetchMyProfile();
      userProfile.value = profile;
    } catch (e) {
      debugPrint("Lỗi Profile: $e");
    }
  }

  // ==========================================
  // GỌI API THẬT CHO HOME DASHBOARD
  // ==========================================
  Future<void> loadAllHomeData() async {
    try {
      isLoading.value = true;

      // Chạy 3 API song song để tiết kiệm thời gian chờ
      final results = await Future.wait([
        _provider.getTransactions(),
        _provider.getLowStockInventories(),
        _provider.getTotalStockQuantity(),
      ]);

      transactions.assignAll(results[0] as List<TransactionModel>);
      lowStockItems.assignAll(results[1] as List<InventoryModel>);
      totalStockQuantity.value = results[2] as int;
    } catch (e) {
      debugPrint("Lỗi load Home Data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, double> _calculateAxisLimits(List<double> values) {
    if (values.isEmpty) return {'min': -1.0, 'max': 4.0, 'interval': 1.25};

    double minVal = values.reduce(min);
    double maxVal = values.reduce(max);

    if (minVal > 0) minVal = 0;
    if (maxVal < 0) maxVal = 0;

    double amplitude = (maxVal - minVal).abs();
    if (amplitude == 0) amplitude = 1.0;

    double padding = amplitude * 0.1;
    double finalMin = (minVal - padding).floorToDouble();
    double tempMax = (maxVal + padding).ceilToDouble();

    double range = tempMax - finalMin;
    double interval = (range / 4).ceilToDouble();
    double finalMax = finalMin + (interval * 4);

    return {'min': finalMin, 'max': finalMax, 'interval': interval};
  }

  // --- REVENUE CALCS ---
  List<FlSpot> get lineChartSpots {
    final today = DateTime.now();
    Map<double, double> hourly = {0.0: 0, 4.0: 0, 8.0: 0, 12.0: 0};

    for (var t in transactions) {
      if (t.createdAt == null) continue;
      final d = t.createdAt!.toLocal();

      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day) {
        final amt = t.totalPrice / 1000;
        final h = d.hour;
        if (h >= 8 && h < 12)
          hourly[0.0] = hourly[0.0]! + amt;
        else if (h >= 12 && h < 16)
          hourly[4.0] = hourly[4.0]! + amt;
        else if (h >= 16 && h < 20)
          hourly[8.0] = hourly[8.0]! + amt;
        else if (h >= 20) hourly[12.0] = hourly[12.0]! + amt;
      }
    }
    return hourly.entries.map((e) => FlSpot(e.key, e.value)).toList();
  }

  Map<String, double> get lineLimits =>
      _calculateAxisLimits(lineChartSpots.map((s) => s.y).toList());

  List<double> get weeklyBarData {
    Map<int, double> daily = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var t in transactions) {
      if (t.createdAt == null) continue;
      final d = t.createdAt!.toLocal();
      daily[d.weekday] = (daily[d.weekday] ?? 0) + (t.totalPrice / 1000);
    }
    return daily.values.toList();
  }

  Map<String, double> get barLimits => _calculateAxisLimits(weeklyBarData);

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
      if (t.createdAt == null) return false;
      final d = t.createdAt!.toLocal();
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).fold(0.0, (sum, t) => sum + t.totalPrice);
  }

  double _sumRevenueByWeek(int weeksAgo) {
    final now = DateTime.now();
    final start =
        now.subtract(Duration(days: now.weekday - 1 + (weeksAgo * 7)));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));

    return transactions.where((t) {
      if (t.createdAt == null) return false;
      return t.createdAt!
              .toLocal()
              .isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.createdAt!.toLocal().isBefore(end);
    }).fold(0.0, (sum, t) => sum + t.totalPrice);
  }

  // --- INVENTORY STATS ---

  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    var filteredList = transactions.where((t) {
      if (t.createdAt == null) return false;
      final d = t.createdAt!.toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    filteredList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return filteredList;
  }

int get stockInToday {
    return todayTransactions
        .where((t) => t.type.toLowerCase() == 'import')
        // ĐÃ FIX: Dùng itemCount, nếu null/0 thì mới fallback về items.length
        .fold<int>(0, (int sum, t) => sum + (t.itemCount > 0 ? t.itemCount : t.items.length));
  }

  int get stockOutToday {
    return todayTransactions
        .where((t) => t.type.toLowerCase() == 'export')
        // ĐÃ FIX: Dùng itemCount
        .fold<int>(0, (int sum, t) => sum + (t.itemCount > 0 ? t.itemCount : t.items.length));
  }
}
