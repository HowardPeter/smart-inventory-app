import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/features/home/model/home_inventory_transaction_model.dart';

class HomeController extends GetxController {
  // ==========================================
  // 1. CÁC BIẾN STATE (GỘP TỪ HEAD VÀ MAIN)
  // ==========================================

  // Từ HEAD (Quản lý Dashboard)
  final RxBool isLoading = true.obs;
  final RxList<HomeInventoryTransactionModel> transactions =
      <HomeInventoryTransactionModel>[].obs;
  final RxList<InventoryModel> inventories = <InventoryModel>[].obs;

  // Từ MAIN (Quản lý User)
  var userProfile = Rxn<UserProfileModel>();
  final UserProfileProvider userProfileProvider = UserProfileProvider();

  // ==========================================
  // 2. LIFECYCLE VÀ GETTERS CƠ BẢN
  // ==========================================

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return TTexts.goodMorning.tr;
    if (hour < 17) return TTexts.goodAfternoon.tr;
    return TTexts.goodEvening.tr;
  }

  @override
  void onInit() {
    super.onInit();
    // Chạy song song cả load data ảo và lấy profile thật
    loadAllHomeData();
    getMyProfile();
  }

  // ==========================================
  // 3. LOGIC TỪ NHÁNH MAIN (API & AUTH)
  // ==========================================

  Future<void> getMyProfile() async {
    try {
      final profile = await userProfileProvider.fetchMyProfile();
      userProfile.value = profile;
      debugPrint(
          "Data user model: ${userProfile.value!.fullName + userProfile.value!.email}");
    } catch (e) {
      debugPrint("Lỗi Không thể lấy thông tin cá nhân: ${e.toString()}");
    }
  }

  // ==========================================
  // 4. LOGIC TỪ NHÁNH HEAD (DASHBOARD & CHARTS)
  // ==========================================

  Future<void> loadAllHomeData() async {
    try {
      isLoading.value = true;
      final String response =
          await rootBundle.loadString('assets/mock_data/home_raw_data.json');
      final data = json.decode(response);

      // Parse Transactions sang Model
      if (data['transactions'] != null) {
        transactions.value = (data['transactions'] as List)
            .map((e) => HomeInventoryTransactionModel.fromJson(
                e as Map<String, dynamic>))
            .toList();
      }

      // --- LOAD INVENTORY ---
      if (data['inventories'] != null) {
        inventories.value = (data['inventories'] as List)
            .map((e) => InventoryModel.fromJson(e))
            .toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIC TÍNH TOÁN KHOẢNG CHIA (INTERVAL) CHO 5 MỐC ---
  Map<String, double> _calculateAxisLimits(List<double> values) {
    if (values.isEmpty) return {'min': -1.0, 'max': 4.0, 'interval': 1.25};

    double minVal = values.reduce(min);
    double maxVal = values.reduce(max);

    // Luôn giữ trục 0 để có đường base line giữa âm và dương
    if (minVal > 0) minVal = 0;
    if (maxVal < 0) maxVal = 0;

    double amplitude = (maxVal - minVal).abs();
    if (amplitude == 0) amplitude = 1.0;

    double padding = amplitude * 0.1; // Thêm 10% padding ở trên và dưới

    // Làm tròn min xuống số nguyên
    double finalMin = (minVal - padding).floorToDouble();
    double tempMax = (maxVal + padding).ceilToDouble();

    // Tính interval và ép nó làm tròn lên số nguyên (hoặc số chẵn)
    double range = tempMax - finalMin;
    double interval = (range / 4).ceilToDouble();

    // QUAN TRỌNG: Tính lại finalMax dựa trên finalMin và interval để đảm bảo lưới chia đều tăm tắp, không bị lẻ số gây dính chữ
    double finalMax = finalMin + (interval * 4);

    return {'min': finalMin, 'max': finalMax, 'interval': interval};
  }

  // --- LINE CHART (Tính theo doanh thu) ---
  List<FlSpot> get lineChartSpots {
    final today = DateTime.now();
    Map<double, double> hourly = {0.0: 0, 4.0: 0, 8.0: 0, 12.0: 0};

    for (var t in transactions) {
      final d = t.createdAt; // Dùng Model
      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day) {
        final amt = t.totalPrice / 1000; // Dùng Model
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

  // --- BAR CHART (Tính theo doanh thu) ---
  List<double> get weeklyBarData {
    Map<int, double> daily = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var t in transactions) {
      final d = t.createdAt;
      daily[d.weekday] = (daily[d.weekday] ?? 0) + (t.totalPrice / 1000);
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
      return t.createdAt.year == date.year &&
          t.createdAt.month == date.month &&
          t.createdAt.day == date.day;
    }).fold(0.0, (sum, t) => sum + t.totalPrice); // Gọi t.totalPrice từ Model
  }

  double _sumRevenueByWeek(int weeksAgo) {
    final now = DateTime.now();
    final start =
        now.subtract(Duration(days: now.weekday - 1 + (weeksAgo * 7)));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));

    return transactions.where((t) {
      return t.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.createdAt.isBefore(end);
    }).fold(0.0, (sum, t) => sum + t.totalPrice);
  }

  // --- INVENTORY STATS ---
  int get totalStockQuantity =>
      inventories.fold(0, (sum, item) => sum + item.quantity);

  // LOGIC ĐẾM CHÍNH XÁC SỐ LƯỢNG ITEM THEO NGÀY
  int get stockInToday {
    final now = DateTime.now();
    int tempStockIn = 0;
    for (var t in transactions) {
      if (t.createdAt.year == now.year &&
          t.createdAt.month == now.month &&
          t.createdAt.day == now.day) {
        // Đếm tổng số lượng trong chi tiết giao dịch
        int qtySum = t.details.fold(0, (sum, detail) => sum + detail.quantity);

        if (t.type == 'refund' || t.type == 'import') {
          tempStockIn += qtySum.abs();
        } else if (t.type == 'adjustment' && qtySum > 0) {
          tempStockIn += qtySum;
        }
      }
    }
    return tempStockIn;
  }

  int get stockOutToday {
    final now = DateTime.now();
    int tempStockOut = 0;
    for (var t in transactions) {
      if (t.createdAt.year == now.year &&
          t.createdAt.month == now.month &&
          t.createdAt.day == now.day) {
        // Đếm tổng số lượng trong chi tiết giao dịch
        int qtySum = t.details.fold(0, (sum, detail) => sum + detail.quantity);

        if (t.type == 'sale') {
          tempStockOut += qtySum.abs();
        } else if (t.type == 'adjustment' && qtySum < 0) {
          tempStockOut += qtySum.abs();
        }
      }
    }
    return tempStockOut;
  }

  // --- RECENT TRANSACTIONS ---
  List<HomeInventoryTransactionModel> get recentTransactions {
    var sortedList = List<HomeInventoryTransactionModel>.from(transactions);
    // Sắp xếp giảm dần theo thời gian sử dụng field createdAt của Model
    sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedList.take(3).toList();
  }

  // --- BỔ SUNG LOGIC LOW STOCK ALERTS ---
  List<InventoryModel> get lowStockItems {
    // Lọc các item có số lượng <= mức cảnh báo
    var lowStockList = inventories
        .where((item) => item.quantity <= item.reorderThreshold)
        .toList();

    // Sắp xếp: Thằng nào quantity = 0 (hết sạch) lên đầu, sau đó tăng dần
    lowStockList.sort((a, b) => a.quantity.compareTo(b.quantity));

    return lowStockList;
  }
}
