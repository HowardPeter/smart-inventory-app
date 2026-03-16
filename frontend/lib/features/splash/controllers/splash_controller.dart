import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/t_custom_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/services/auth_service.dart';

class SplashController extends GetxController {
  // 1. State variables
  final RxDouble progress = 0.0.obs;
  final RxString loadingMessage =
      'Khởi động hệ thống...'.obs; // Thêm biến lưu text loading

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // 3. Private methods
  Future<void> _initializeApp() async {
    // Định nghĩa danh sách các tác vụ và dòng chữ hiển thị tương ứng
    final List<Map<String, dynamic>> tasks = [
      {
        'message': 'Checking internet connection...',
        'action': _checkInternetConnection,
      },
      {'message': 'Loading system settings...', 'action': _loadSystemSettings},
      {'message': 'Loading core services...', 'action': _initCoreServices},
      {'message': 'Verifying user data...', 'action': _checkUserAuthentication},
    ];

    // Chạy tuần tự từng tác vụ
    for (int i = 0; i < tasks.length; i++) {
      loadingMessage.value = tasks[i]['message']; // Cập nhật chữ hiển thị

      try {
        await tasks[i]['action'](); // Thực thi hàm
      } catch (e) {
        // Nếu có lỗi Exception văng ra ở bất kỳ task nào, bạn có thể xử lý ở đây
        debugPrint('Lỗi ở task ${tasks[i]['message']}: $e');
        // Tuỳ trường hợp, bạn có thể Get.dialog báo lỗi ròi cho đi tiếp hoặc dừng hẳn
      }

      progress.value = (i + 1) / tasks.length; // Cập nhật thanh Load
    }

    loadingMessage.value = 'Done!'; // Xong 100%
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Dừng nửa giây cho đẹp
    _navigateToNextScreen();
  }

  /// TÁC VỤ 1: KIỂM TRA INTERNET CÓ DIALOG
  Future<void> _checkInternetConnection() async {
    bool hasInternet = await _checkConnectivityDirectly();

    // Vòng lặp vô hạn: Chừng nào chưa có mạng thì cứ hiện Dialog đòi mạng (trừ khi bấm Got it)
    while (!hasInternet) {
      // Gọi cái Khuôn dùng chung ra và bơm nội dung riêng của lỗi mạng vào
      final userChoice = await Get.dialog<String>(
        TCustomDialog(
          icon: const Text(
            '📡',
            style: TextStyle(fontSize: 40),
          ), // Truyền cái hộp vô
          title: 'No Internet Connection',
          description:
              'You are offline. Your actions will not be saved to the cloud. Do you want to continue offline or check your connection?',

          // Cấu hình Nút phụ (Màu xám)
          secondaryButtonText: 'Got it!',
          onSecondaryPressed: () => Get.back(result: 'got_it'),

          // Cấu hình Nút chính (Màu cam)
          primaryButtonText: 'Check my Wifi',
          onPrimaryPressed: () => Get.back(result: 'check_wifi'),
        ),
        barrierDismissible: false,
      );

      if (userChoice == 'got_it') {
        // Bấm Got it -> Thoát khỏi vòng lặp check mạng -> Cho phép code chạy tiếp các task bên dưới
        break;
      } else if (userChoice == 'check_wifi') {
        // Bấm Check Wifi -> Mở setting điện thoại
        AppSettings.openAppSettings(type: AppSettingsType.wifi);

        // Đợi người dùng đổi mạng trong 3 giây rồi tự động quay lại vòng lặp check lại
        loadingMessage.value = 'Waiting for network...';
        await Future.delayed(const Duration(seconds: 3));
        hasInternet = await _checkConnectivityDirectly();
      }
    }
  }

  /// Hàm phụ trợ check mạng thật sự
  Future<bool> _checkConnectivityDirectly() async {
    // 1. Kiểm tra xem có đang kết nối phần cứng nào không (Wifi/3G/Ethernet)
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('Không bật Wifi/3G');
      return false;
    }

    // 2. KIỂM TRA INTERNET THẬT (Ping thử tới Google)
    try {
      // Lệnh này sẽ thử tìm địa chỉ IP của google.com
      final result = await InternetAddress.lookup('google.com');

      // Nếu tìm thấy và có dữ liệu trả về -> Chắc chắn 100% có mạng
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('Có Internet thật sự!');
        return true;
      }
    } on SocketException catch (_) {
      // Bắt lỗi: Có sóng Wifi nhưng mất mạng (chưa đóng tiền mạng, rớt cáp quang...)
      debugPrint('Có sóng nhưng không có Internet (SocketException)');
      return false;
    }

    return false;
  }

  /// TÁC VỤ 2: Load data ứng dụng
  Future<void> _loadSystemSettings() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // TÁC VỤ 3: Load các core Service của hệ thống
  Future<void> _initCoreServices() async {
    await Get.putAsync(() => AuthService().init());
  }

  /// TÁC VỤ 4: Xác thực Token với Server (Fake API)
  Future<void> _checkUserAuthentication() async {
    final authService = Get.find<AuthService>();

    // 1. Nếu ổ cứng báo là CHƯA từng đăng nhập -> Bỏ qua, không cần lên Server hỏi mất công
    if (!authService.isLoggedIn.value) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Delay cho mượt UI
      return;
    }

    // 2. Nếu ổ cứng báo ĐÃ đăng nhập -> Mang Token lên Server kiểm tra (Verify)
    try {
      // TODO: Sau này có API thật, sẽ gọi: await Get.find<AuthProvider>().verifyToken();

      // Hiện tại: Mô phỏng việc gọi API lên Server mất 1.5 giây
      await Future.delayed(const Duration(milliseconds: 1500));

      // Giả lập logic: Nếu thành công, Server trả về OK -> Giữ nguyên trạng thái isLoggedIn = true
      debugPrint('Xác thực thành công: Token còn hạn hợp lệ!');

      /* // TEST TRƯỜNG HỢP TOKEN HẾT HẠN, \ MỞ COMMENT DÒNG DƯỚI ĐÂY:
      // throw Exception('Token expired'); 
      */
    } catch (e) {
      // 3. Nếu Server báo lỗi (Token hết hạn, User bị khóa, hoặc lỗi mạng lúc check)
      debugPrint('Xác thực thất bại: $e');

      // GỌI BÁC BẢO VỆ XÓA SẠCH DỮ LIỆU VÀ ĐÁ VỀ TRẠNG THÁI CHƯA ĐĂNG NHẬP
      await authService.logout();

      // Lưu ý: Lúc này authService.isLoggedIn.value đã biến thành false.
      // Khi hàm _navigateToNextScreen() chạy, nó sẽ tự động ném user về trang Login.
    }
  }

  void _navigateToNextScreen() {
    // Logic Onboarding -> Home -> Login của bạn ở đây (Giữ nguyên)
    final storage = GetStorage();
    final authService = Get.find<AuthService>();
    final isFirstTime = storage.read('IS_FIRST_TIME') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authService.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
