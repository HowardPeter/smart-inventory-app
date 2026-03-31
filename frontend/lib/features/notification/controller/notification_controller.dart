import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/notification_model.dart';
import 'package:frontend/features/notification/providers/notification_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends GetxController {
  final NotificationProvider _provider = NotificationProvider();

  // State quản lý danh sách và loading
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var isLoadMore = false.obs;
  var unreadCount = 0.obs;

  // Logic phân trang
  final ScrollController scrollController = ScrollController();
  int _currentPage = 1; // Backend thường dùng page 1 làm trang đầu tiên
  final int _pageSize = 15;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _setupPagination();
    _setupRealtime();
  }

  // ==========================================
  // 1. SETUP REALTIME (SUPABASE)
  // ==========================================
  void _setupRealtime() {
    // Tạm thời hardcode userId để test, sau này bạn lấy từ State management của bạn (GetX/Provider)
    const currentUserId = '665ef842-704d-4479-b996-fc9e2c663587';

    if (currentUserId.isEmpty) return;

    Supabase.instance.client
        .channel('public:notification')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          // 👇 SỬA Ở ĐÂY: Chữ 'notification' phải viết thường y hệt trong Database
          table: 'notification',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column:
                'user_id', // 👈 LƯU Ý: Prisma thường map xuống DB là snake_case.
            // Bạn hãy check lại trong bảng notification xem cột lưu ID
            // người dùng là 'userId' hay 'user_id' để truyền cho đúng nhé!
            value: currentUserId,
          ),
          callback: (payload) {
            debugPrint(
                '🔔 REALTIME BÁO CÓ THÔNG BÁO MỚI: ${payload.newRecord}');

            // Tải lại danh sách từ trang 1
            fetchNotifications();
          },
        )
        .subscribe();
  }

  // ==========================================
  // 2. PHÂN TRANG
  // ==========================================
  void _setupPagination() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!_hasMore || isLoadMore.value || isLoading.value) return;
        fetchMoreNotifications();
      }
    });
  }

  Future<void> fetchNotifications() async {
    try {
      _currentPage = 1;
      _hasMore = true;
      isLoading.value = true;

      final response = await _provider.fetchNotifications(
          page: _currentPage, size: _pageSize);

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        notifications.value =
            data.map((json) => NotificationModel.fromJson(json)).toList();

        if (data.length < _pageSize) _hasMore = false;
        _updateUnreadCount();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreNotifications() async {
    try {
      isLoadMore.value = true;
      _currentPage++;

      final response = await _provider.fetchNotifications(
          page: _currentPage, size: _pageSize);

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        if (data.isEmpty) {
          _hasMore = false;
        } else {
          final nextItems =
              data.map((json) => NotificationModel.fromJson(json)).toList();
          notifications.addAll(nextItems);
          if (data.length < _pageSize) _hasMore = false;
        }
      }
    } finally {
      isLoadMore.value = false;
    }
  }

  // ==========================================
  // 3. LOGIC XỬ LÝ DỮ LIỆU
  // ==========================================
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.notificationId == id);
    if (index == -1 || notifications[index].isRead) return;

    notifications[index].isRead = true;
    notifications.refresh();
    _updateUnreadCount();

    try {
      await _provider.markAsRead(id);
    } catch (e) {
      debugPrint("⚠️ Lỗi API markAsRead: $e");
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    for (var noti in notifications) {
      noti.isRead = true;
    }
    notifications.refresh();
    _updateUnreadCount();

    try {
      await _provider.markAllAsRead();
    } catch (e) {
      debugPrint("⚠️ Lỗi API markAllAsRead: $e");
    }
  }

  // ==========================================
  // XÓA THÔNG BÁO CÓ HỖ TRỢ HOÀN TÁC (UNDO)
  // ==========================================
  void deleteNotificationWithUndo(NotificationModel item, int index) {
    final context = Get.context;
    if (context == null) return;

    // 1. Xóa tạm thời khỏi UI
    notifications.removeAt(index);
    _updateUnreadCount();

    bool isUndone = false;

    // 2. Gọi Helper lấy giao diện SnackBar
    final snackbar = TSnackbarsWidget.undoSnackBar(
      context: context,
      title: "Đã xóa thông báo",
      message: "Có thể hoàn tác trong 5 giây",
      onUndo: () {
        // Logic hoàn tác (Chỉ Controller mới được quyền sửa data)
        isUndone = true;
        int safeIndex =
            index > notifications.length ? notifications.length : index;
        notifications.insert(safeIndex, item);
        _updateUnreadCount();
      },
    );

    // Xóa snackbar cũ nếu có
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 3. Hiển thị và xử lý luồng API ngầm
    ScaffoldMessenger.of(context)
        .showSnackBar(snackbar)
        .closed
        .then((reason) async {
      if (!isUndone && reason != SnackBarClosedReason.action) {
        try {
          await _provider.deleteNotification(item.notificationId);
          debugPrint("✅ Đã xóa thật: ${item.notificationId}");
        } catch (e) {
          debugPrint("⚠️ Lỗi API xóa thông báo: $e");

          // Rollback data
          int safeIndex =
              index > notifications.length ? notifications.length : index;
          notifications.insert(safeIndex, item);
          _updateUnreadCount();

          TSnackbarsWidget.error(
              title: "Lỗi kết nối",
              message: "Không thể xóa thông báo vào lúc này.");
        }
      }
    });
  }

  // Hàm fomat thời gian chuẩn
  String formatTimeAgo(dynamic timeData) {
    if (timeData == null) return '';
    try {
      DateTime date = (timeData is DateTime)
          ? timeData.toLocal()
          : DateTime.parse(timeData.toString()).toLocal();
      final difference = DateTime.now().difference(date);

      if (difference.inDays > 7) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return '';
    }
  }
}
