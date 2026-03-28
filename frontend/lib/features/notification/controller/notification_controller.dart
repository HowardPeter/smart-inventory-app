import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/notification_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class NotificationController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // Biến state GetX
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // LẤY DANH SÁCH THÔNG BÁO TỪ BACKEND
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      // ApiClient đã tự động gắn Token và x-store-id vào header
      // và baseUrl đã có sẵn /api nên chỉ cần gọi '/notification'
      final response = await _apiClient.get('/notification');

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        notifications.value =
            data.map((json) => NotificationModel.fromJson(json)).toList();

        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint("❌ Lỗi fetch notifications: $e");
      TSnackbarsWidget.error(
        title: "Lỗi",
        message: "Không thể tải thông báo. Vui lòng thử lại sau.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ĐẾM SỐ LƯỢNG CHƯA ĐỌC (Hiển thị chấm đỏ)
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // ĐÁNH DẤU ĐÃ ĐỌC (Tối ưu UI Real-time)
  Future<void> markAsRead(String id) async {
    // 1. Tìm thông báo trong RAM
    final index = notifications.indexWhere((n) => n.notificationId == id);
    if (index == -1 || notifications[index].isRead) return;

    // 2. Cập nhật UI ngay lập tức (Optimistic Update)
    notifications[index].isRead = true;
    notifications.refresh(); // Ép GetX vẽ lại màn hình
    _updateUnreadCount();

    // 3. Gọi API chạy ngầm
    try {
      await _apiClient.patch('/notification/$id/read');
    } catch (e) {
      debugPrint("⚠️ Lỗi API markAsRead: $e");
      // (Tuỳ chọn) Rollback UI nếu API lỗi
      // notifications[index].isRead = false;
      // notifications.refresh();
      // _updateUnreadCount();
    }
  }

  // ĐÁNH DẤU ĐỌC TẤT CẢ (Tính năng cộng thêm)
  Future<void> markAllAsRead() async {
    final unreadList = notifications.where((n) => !n.isRead).toList();
    if (unreadList.isEmpty) return;

    for (var n in unreadList) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;

    // Gọi API từng cái hoặc báo Backend làm thêm API /notification/read-all
    for (var n in unreadList) {
      _apiClient
          .patch('/notification/${n.notificationId}/read')
          // ignore: body_might_complete_normally_catch_error
          .catchError((e) {
        debugPrint("Lỗi patch: $e");
      });
    }
  }

  // XÓA THÔNG BÁO (Vuốt ngang để xóa)
  Future<void> deleteNotification(String id) async {
    final index = notifications.indexWhere((n) => n.notificationId == id);
    if (index == -1) return;

    // 1. Lưu bản backup để rollback nếu API lỗi
    final backupItem = notifications[index];

    // 2. Xóa khỏi UI ngay lập tức
    notifications.removeAt(index);
    _updateUnreadCount();

    // 3. Gọi API chạy ngầm
    try {
      await _apiClient.delete('/notification/$id');
    } catch (e) {
      debugPrint("❌ Lỗi API xóa thông báo: $e");

      // Rollback lại UI nếu mất mạng
      notifications.insert(index, backupItem);
      _updateUnreadCount();

      TSnackbarsWidget.error(
        title: "Lỗi",
        message: "Không thể xóa thông báo do lỗi kết nối.",
      );
    }
  }
}
