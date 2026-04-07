import 'package:get/get.dart';

class ReportController extends GetxController {
  final RxString activeTab = 'Today'.obs;

  void changeTab(String tab) {
    activeTab.value = tab;
  }

  // Lấy chuỗi Ngày (VD: April 7,)
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

  // Lấy chuỗi Thứ (VD: Tuesday)
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
