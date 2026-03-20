class AppConstants {
  // Cấu hình API Backend
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Thời gian chờ API (Timeout)
  static const int connectionTimeout = 15000; // 15 giây
  static const int receiveTimeout = 15000;

  // Các Keys lưu trữ Local Storage (SharedPreferences/GetStorage)
  static const String tokenKey = 'ACCESS_TOKEN';
  static const String userKey = 'USER_INFO';
}
