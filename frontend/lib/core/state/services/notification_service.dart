import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart'; // Import đúng ApiClient của bạn

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Khởi tạo ApiClient (Đã tự động lấy token Supabase gắn vào header)
  static final ApiClient _apiClient = ApiClient();

  static Future<void> initialize() async {
    // 1. XIN QUYỀN (Bắt buộc cho iOS & Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. SETUP LOCAL NOTIFICATION (Dành cho Foreground)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Xử lý khi user click vào thông báo lúc app ĐANG MỞ
      },
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Khớp 100% với BE Node.js
      'High Importance Notifications',
      description: 'Dùng cho các thông báo quan trọng.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. LẮNG NGHE KHI APP ĐANG MỞ (Foreground) -> Hiển thị popup nổi
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode, // <-- Thêm id:
          title: notification.title, // <-- Thêm title:
          body: notification.body, // <-- Thêm body:
          notificationDetails: NotificationDetails(
            // <-- Thêm notificationDetails:
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // 4. XỬ LÝ CLICK VÀO THÔNG BÁO TỪ TRẠNG THÁI NGẦM (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // 5. XỬ LÝ CLICK VÀO THÔNG BÁO TỪ TRẠNG THÁI TẮT HOÀN TOÀN (Terminated)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(initialMessage);
      });
    }

    // 6. LẮNG NGHE ĐỔI TOKEN (Firebase tự đổi định kỳ)
    _messaging.onTokenRefresh.listen((newToken) {
      // Gọi API cập nhật nếu cần, thường ApiClient tự có session token rồi
      registerTokenWithBackend();
    });
  }

  // --- HÀM XỬ LÝ CHUYỂN TRANG BẰNG GETX ---
  static void _handleNotificationTap(RemoteMessage message) {
    // Đọc payload "data" gửi từ Node.js (biến dataPayload trong sendNotification)
    final data = message.data;

    // Ví dụ cấu trúc data từ BE: { "type": "lesson", "lessonId": "123" }
    if (data['type'] == 'lesson') {
      Get.toNamed('/lesson-detail', arguments: data['lessonId']);
    } else if (data['type'] == 'profile') {
      Get.toNamed('/profile');
    }
  }

  // --- CÁC HÀM GỌI API ĐẾN NODE.JS ---

  static Future<void> registerTokenWithBackend() async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        debugPrint("⚠️ [FCM] Không sinh được token từ thiết bị!");
        return;
      }

      await _apiClient.post(
        '/api/notification/register-token',
        data: {'token': fcmToken},
      );
      debugPrint("✅ [FCM] Đăng ký token lên server thành công");
    } on DioException catch (e) {
      // Bắt chính xác lỗi từ API trả về (Cực kỳ hữu ích để debug)
      debugPrint(
          "❌ [FCM] Lỗi gọi API Dio: HTTP ${e.response?.statusCode} - ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ [FCM] Lỗi hệ thống chưa xác định: $e");
    }
  }

  static Future<void> removeTokenFromBackend() async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      await _apiClient.post(
        '/api/notification/remove-token',
        data: {'token': fcmToken},
      );

      await _messaging.deleteToken();
      debugPrint("✅ [FCM] Đã xóa token thành công");
    } on DioException catch (e) {
      debugPrint(
          "❌ [FCM] Lỗi gọi API Dio khi xóa: HTTP ${e.response?.statusCode} - ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ [FCM] Lỗi xóa token: $e");
    }
  }
}
