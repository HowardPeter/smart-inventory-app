// lib/core/infrastructure/utils/t_formatter_utils.dart
import 'package:intl/intl.dart';

class DayFormatterUtils {
  // ==========================================
  // 1. DÀNH CHO API (GỬI LÊN BACKEND)
  // Đảm bảo tuyệt đối format YYYY-MM-DD không chứa giờ phút
  // ==========================================
  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ==========================================
  // 2. DÀNH CHO UI (HIỂN THỊ TRÊN MÀN HÌNH APP)
  // Tự động dịch từ giờ UTC của Backend sang Local Time (Ví dụ: UTC+7)
  // ==========================================
  static String formatDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
    if (date == null) return 'N/A';
    return DateFormat(format).format(date.toLocal());
  }

  static String formatDateTime(DateTime? date,
      {String format = 'dd/MM/yyyy HH:mm'}) {
    if (date == null) return 'N/A';
    return DateFormat(format).format(date.toLocal());
  }
}
