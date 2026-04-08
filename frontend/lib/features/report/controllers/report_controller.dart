import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReportController extends GetxController {
  final _box = GetStorage();

  // Trạng thái chung
  final RxString activeTab = 'Today'.obs;
  final RxBool isLoading = true.obs;

  // Dữ liệu
  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;

  // Trạng thái của Calendar
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Lấy trạng thái Tab đã lưu từ Local Storage (Mặc định là Today)
    activeTab.value = _box.read('report_active_tab') ?? 'Today';
    fetchMockData();
  }

  void changeTab(String tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    // Lưu xuống Local Storage
    _box.write('report_active_tab', tab);
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  // Hàm lấy danh sách giao dịch cho 1 ngày cụ thể (Dùng để vẽ chấm trên lịch)
  List<TransactionModel> getTransactionsForDay(DateTime day) {
    return allTransactions.where((tx) {
      if (tx.createdAt == null) return false;
      return isSameDay(tx.createdAt!, day);
    }).toList();
  }

  // Hàm lọc dữ liệu để hiển thị bên dưới View
  List<TransactionModel> get filteredTransactions {
    final targetDay =
        activeTab.value == 'Today' ? DateTime.now() : selectedDay.value;
    return getTransactionsForDay(targetDay);
  }

  // Tiện ích so sánh ngày (bỏ qua giờ phút giây)
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> fetchMockData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000)); // Fake delay

    final today = DateTime.now();
    // Tạo Mock Data động dựa vào ngày hiện tại để bạn test Lịch dễ dàng
    allTransactions.assignAll([
      TransactionModel(
          transactionId: 'TRX-001',
          type: 'ADJUSTMENT',
          status: 'COMPLETED',
          totalPrice: 0,
          createdAt: today,
          items: []),
      TransactionModel(
          transactionId: 'TRX-002',
          type: 'INBOUND',
          status: 'COMPLETED',
          totalPrice: 150000,
          createdAt: today,
          items: []),
      TransactionModel(
          transactionId: 'TRX-003',
          type: 'OUTBOUND',
          status: 'COMPLETED',
          totalPrice: 50000,
          createdAt: today,
          items: []),
      TransactionModel(
          transactionId: 'TRX-004',
          type: 'INBOUND',
          status: 'COMPLETED',
          totalPrice: 20000,
          createdAt: today,
          items: []), // Chấm thứ 4 sẽ bị ẩn theo yêu cầu max 3

      TransactionModel(
          transactionId: 'TRX-005',
          type: 'OUTBOUND',
          status: 'COMPLETED',
          totalPrice: 120000,
          createdAt: today.subtract(const Duration(days: 1)),
          items: []),
      TransactionModel(
          transactionId: 'TRX-006',
          type: 'ADJUSTMENT',
          status: 'COMPLETED',
          totalPrice: 0,
          createdAt: today.subtract(const Duration(days: 2)),
          items: []),
      TransactionModel(
          transactionId: 'TRX-007',
          type: 'INBOUND',
          status: 'COMPLETED',
          totalPrice: 30000,
          createdAt: today.subtract(const Duration(days: 2)),
          items: []),
    ]);

    isLoading.value = false;
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
