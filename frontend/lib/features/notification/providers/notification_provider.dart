import 'package:frontend/core/infrastructure/network/app_client.dart';

class NotificationProvider {
  final ApiClient _apiClient = ApiClient();

  // Lấy danh sách từ Backend có phân trang
  Future<dynamic> fetchNotifications(
      {int page = 0, int size = 15, String type = 'ALL'}) async {
    return await _apiClient.get(
      '/api/notification',
      queryParameters: {
        'page': page,
        'size': size,
        'type': type,
      },
    );
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/api/notification/$id/read');
  }

  // Đánh dấu đã đọc tất cả
  Future<void> markAllAsRead() async {
    await _apiClient.patch('/api/notification/read-all');
  }

  // Xóa thông báo
  Future<void> deleteNotification(String id) async {
    await _apiClient.delete('/api/notification/$id');
  }
}
