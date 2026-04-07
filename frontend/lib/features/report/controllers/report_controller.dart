import 'package:get/get.dart';

class ReportController extends GetxController {
  final RxString activeTab = 'Today'.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockData();
  }

  void changeTab(String tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    fetchMockData();
  }

  Future<void> fetchMockData() async {
    isLoading.value = true;
    // Giả lập thời gian call API mất 1.5 giây để show Shimmer
    await Future.delayed(const Duration(milliseconds: 1500));
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
