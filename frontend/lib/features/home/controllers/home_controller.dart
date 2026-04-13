import 'dart:convert';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/home/model/home_adjustment_model.dart';
import 'package:frontend/features/home/providers/home_provider.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';

class HomeController extends GetxController with TErrorHandler {
  final HomeProvider _provider = HomeProvider();

  final RxBool isLoading = true.obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<InventoryModel> lowStockItems = <InventoryModel>[].obs;
  final RxInt totalStockQuantity = 0.obs;

  final RxInt itemsLostToday = 0.obs;
  final RxInt itemsFoundToday = 0.obs;
  final RxList<HomeAdjustmentModel> todayAdjustments =
      <HomeAdjustmentModel>[].obs;

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

  Future<void> loadAllHomeData() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _provider.getTransactions(),
        _provider.getLowStockInventories(),
        _provider.getAllInventories(),
        _provider.getTodayAuditLogs(),
      ]);

      transactions.assignAll(results[0] as List<TransactionModel>);
      lowStockItems.assignAll(results[1] as List<InventoryModel>);

      // ==============================================================
      // 1. TẠO TỪ ĐIỂN TÊN SẢN PHẨM (DÙNG CẢ 2 ID ĐỂ KHÔNG BAO GIỜ TRƯỢT)
      // ==============================================================
      final allInventories = results[2] as List<InventoryModel>;
      totalStockQuantity.value =
          allInventories.fold<int>(0, (sum, item) => sum + item.quantity);

      final Map<String, String> nameLookup = {};
      for (var inv in allInventories) {
        if (inv.productPackage != null) {
          nameLookup[inv.productPackageId] = inv.productPackage!.displayName;
          nameLookup[inv.inventoryId] = inv
              .productPackage!.displayName; // Ánh xạ dự phòng bằng Inventory ID
        }
      }

      // ==============================================================
      // 2. PARSE AUDIT LOG VÀ TÌM TÊN SẢN PHẨM
      // ==============================================================
      final logs = results[3] as List<Map<String, dynamic>>;
      int lost = 0;
      int found = 0;
      final List<HomeAdjustmentModel> parsedAdjustments = [];

      for (var log in logs) {
        dynamic oldRaw = log['oldValue'] ?? log['old_value'];
        dynamic newRaw = log['newValue'] ?? log['new_value'];

        Map<String, dynamic> oldVal = {};
        Map<String, dynamic> newVal = {};

        // Ép kiểu JSON từ String (Nếu backend trả về chuỗi bọc ngoặc kép)
        if (oldRaw is String) {
          try {
            oldVal = jsonDecode(oldRaw);
          } catch (_) {}
        } else if (oldRaw is Map) {
          oldVal = Map<String, dynamic>.from(oldRaw);
        }

        if (newRaw is String) {
          try {
            newVal = jsonDecode(newRaw);
          } catch (_) {}
        } else if (newRaw is Map) {
          newVal = Map<String, dynamic>.from(newRaw);
        }

        int oldQty = int.tryParse(oldVal['quantity']?.toString() ?? '0') ?? 0;
        int newQty = int.tryParse(newVal['quantity']?.toString() ?? '0') ?? 0;
        int diff = newQty - oldQty;

        if (diff < 0) lost += diff.abs();
        if (diff > 0) found += diff;

        // Quét Tên Sản Phẩm bằng CẢ 2 loại ID
        String pName = '';
        final String? pkgId = newVal['productPackageId']?.toString();
        final String? entityId =
            log['entity_id']?.toString() ?? log['entityId']?.toString();

        if (pkgId != null && nameLookup.containsKey(pkgId)) {
          pName = nameLookup[pkgId]!;
        } else if (entityId != null && nameLookup.containsKey(entityId)) {
          pName =
              nameLookup[entityId]!; // Dò bằng Inventory ID của bảng AuditLog
        } else {
          // Chỉ fallback về chữ System khi tìm mọi cách mà vẫn vô vọng
          pName = log['note']?.toString() ?? '';
          if (pName.isEmpty ||
              pName == 'Stock Take' ||
              pName == 'System Adjustment') {
            pName = TTexts.systemAdjustment.tr;
          }
        }

        // Format thời gian & Gắn ID (Hỗ trợ cả event_id của DB mới)
        final dateStr = log['performedAt'] ??
            log['performed_at'] ??
            DateTime.now().toIso8601String();
        final date = DateTime.parse(dateStr).toLocal();
        final id = log['id']?.toString() ??
            log['event_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();

        parsedAdjustments.add(HomeAdjustmentModel(
          id: id,
          productName: pName,
          difference: diff,
          time: date,
        ));
      }

      itemsLostToday.value = lost;
      itemsFoundToday.value = found;
      todayAdjustments.assignAll(parsedAdjustments);
    } catch (e) {
      debugPrint("Lỗi load Home Data: $e");
      handleError(e); // ĐÃ THÊM: Gọi SnackBar bắt lỗi
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // CÁC HÀM DOANH THU & LOGIC BIỂU ĐỒ (GIỮ NGUYÊN HOÀN TOÀN)
  // ==========================================================
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
    final importQty = todayTransactions
        .where((t) => t.type.toLowerCase() == 'import')
        .fold<int>(
            0,
            (int sum, t) =>
                sum + (t.itemCount > 0 ? t.itemCount : t.items.length));
    return importQty + itemsFoundToday.value;
  }

  int get stockOutToday {
    final exportQty = todayTransactions
        .where((t) => t.type.toLowerCase() == 'export')
        .fold<int>(
            0,
            (int sum, t) =>
                sum + (t.itemCount > 0 ? t.itemCount : t.items.length));
    return exportQty + itemsLostToday.value;
  }
}
