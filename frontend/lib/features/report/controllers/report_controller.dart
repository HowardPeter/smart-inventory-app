import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/report/providers/report_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReportController extends GetxController with TErrorHandler {
  final _box = GetStorage();
  late final ReportProvider _provider;

  final RxString activeTab = 'Today'.obs;
  final RxBool isLoading = true.obs;
  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _provider = ReportProvider();
    activeTab.value = _box.read('report_active_tab') ?? 'Today';

    fetchTransactions(); // ĐÃ FIX: Gọi hàm gọi API thật
  }

  void changeTab(String tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    _box.write('report_active_tab', tab);
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;

      final now = DateTime.now();

      // ĐÃ FIX: Dùng Helper ép cứng ra định dạng "2026-03-01", không còn lỗi Zod!
      final startDateStr =
          DayFormatterUtils.formatApiDate(DateTime(now.year, now.month - 1, 1));
      final endDateStr =
          DayFormatterUtils.formatApiDate(DateTime(now.year, now.month + 1, 0));

      final data = await _provider.getTransactions(queryParams: {
        'limit': 100,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        'startDate': startDateStr,
        'endDate': endDateStr,
      });

      allTransactions.assignAll(data);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionModel> getTransactionsForDay(DateTime day) {
    return allTransactions.where((tx) {
      if (tx.createdAt == null) return false;
      return isSameDay(tx.createdAt!.toLocal(), day);
    }).toList();
  }

  List<TransactionModel> get filteredTransactions {
    final targetDay =
        activeTab.value == 'Today' ? DateTime.now() : selectedDay.value;
    return getTransactionsForDay(targetDay);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get currentDateStr {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day},';
  }

  String get currentDayStr {
    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[now.weekday - 1];
  }
}
