import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

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
        AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // (Tùy chọn nâng cao) Xử lý khi user click vào popup Local Notification lúc app ĐANG MỞ
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
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@drawable/ic_notification',
              color: const Color(
                  0x00ff7a03),
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
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
      registerTokenWithBackend();
    });
  }

  // --- BỘ ĐỊNH TUYẾN THÔNG MINH ---
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    // Trích xuất data payload chuẩn
    final String type = data['type'] ?? 'UNKNOWN';
    final String referenceId = data['referenceId'] ?? '';
    final String notificationId = data['notificationId'] ?? '';

    debugPrint(
        "🔔 [FCM] User click thông báo: type=$type, refId=$referenceId, notiId=$notificationId");

    // Gọi API báo đã đọc chạy ngầm (Dùng PATCH)
    if (notificationId.isNotEmpty) {
      // Dùng async/await lồng trong một Future không chặn (fire-and-forget)
      () async {
        try {
          await _apiClient.patch('api/notification/$notificationId/read');
        } catch (e) {
          debugPrint("⚠️ [FCM] Lỗi update trạng thái read: $e");
        }
      }();
    }

    // TODO: Điều hướng GetX dựa theo Use Case
    switch (type) {
      case 'LOW_STOCK': // Cảnh báo sắp hết hàng
      case 'REORDER_SUGGESTION': // Gợi ý nhập hàng
        if (referenceId.isNotEmpty) {
          // Bạn nhớ đổi tên route này cho khớp với app của bạn nhé
         // Get.toNamed('/product-detail', arguments: referenceId);
        } else {
         // Get.toNamed('/notification-center');
        }
        break;

      case 'ABNORMAL_DISCREPANCY': // Cảnh báo biến động tồn kho bất thường
        if (referenceId.isNotEmpty) {
          //Get.toNamed('/inventory-adjustment-history', arguments: referenceId);
        } else {
         // Get.toNamed('/notification-center');
        }
        break;

      default:
        // Các thông báo chung (Ví dụ tin tức, update hệ thống...)
      //  Get.toNamed('/notification-center');
        break;
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

      // Đã sửa lại đường dẫn, bỏ /api
      await _apiClient.post(
        '/api/notification/register-token',
        data: {'token': fcmToken},
      );
      debugPrint("✅ [FCM] Đăng ký token lên server thành công");
    } on DioException catch (e) {
      // Bắt lỗi chi tiết để trị lỗi null-null
      debugPrint("❌ [FCM] Lỗi gọi API Dio đăng ký token:");
      debugPrint("   - Type: ${e.type}");
      debugPrint("   - Message: ${e.message}");
      debugPrint("   - Status: ${e.response?.statusCode}");
      debugPrint("   - Data: ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ [FCM] Lỗi hệ thống chưa xác định: $e");
    }
  }

  static Future<void> removeTokenFromBackend() async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      // Đã sửa lại đường dẫn, bỏ /api
      await _apiClient.post(
        '/api/notification/remove-token',
        data: {'token': fcmToken},
      );

      await _messaging.deleteToken();
      debugPrint("✅ [FCM] Đã xóa token thành công");
    } on DioException catch (e) {
      // Bắt lỗi chi tiết để trị lỗi null-null
      debugPrint("❌ [FCM] Lỗi gọi API Dio xóa token:");
      debugPrint("   - Type: ${e.type}");
      debugPrint("   - Message: ${e.message}");
      debugPrint("   - Status: ${e.response?.statusCode}");
      debugPrint("   - Data: ${e.response?.data}");
    } catch (e) {
      debugPrint("❌ [FCM] Lỗi xóa token: $e");
    }
  }
}
