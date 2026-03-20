import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/text_strings.dart';
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
  final RxString loadingMessage = TTexts.splashLoadingStart.tr.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // 3. Private methods
  Future<void> _initializeApp() async {
    // 2. Cập nhật danh sách Tasks dùng Locale
    final List<Map<String, dynamic>> tasks = [
      {
        'message': TTexts.splashLoadingInternet.tr, // Dùng .tr ở đây
        'action': _checkInternetConnection,
      },
      {
        'message': TTexts.splashLoadingSettings.tr,
        'action': _loadSystemSettings,
      },
      {'message': TTexts.splashLoadingServices.tr, 'action': _initCoreServices},
      {
        'message': TTexts.splashLoadingUser.tr,
        'action': _checkUserAuthentication,
      },
    ];

    for (int i = 0; i < tasks.length; i++) {
      loadingMessage.value = tasks[i]['message'];

      await tasks[i]['action']();

      progress.value = (i + 1) / tasks.length;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _navigateToNextScreen();
  }

  /// TÁC VỤ 1: KIỂM TRA INTERNET CÓ DIALOG
  Future<void> _checkInternetConnection() async {
    bool hasInternet = await _checkConnectivityDirectly();

    while (!hasInternet) {
      final userChoice = await Get.dialog<String>(
        TCustomDialog(
          icon: const Text('📡', style: TextStyle(fontSize: 40)),
          title: TTexts.netErrorTitle.tr, // Đã dùng Locale
          description: TTexts.netErrorDescription.tr, // Đã dùng Locale
          // Nút phụ
          secondaryButtonText: TTexts.netErrorSecondaryBtn.tr,
          onSecondaryPressed: () => Get.back(result: 'got_it'),

          // Nút chính
          primaryButtonText: TTexts.netErrorPrimaryBtn.tr,
          onPrimaryPressed: () => Get.back(result: 'check_wifi'),
        ),
        barrierDismissible: false,
      );

      if (userChoice == 'got_it') {
        break;
      } else if (userChoice == 'check_wifi') {
        AppSettings.openAppSettings(type: AppSettingsType.wifi);

        // Thông báo chờ mạng cũng dùng Locale
        loadingMessage.value = TTexts.netErrorWaiting.tr;

        await Future.delayed(const Duration(seconds: 3));
        hasInternet = await _checkConnectivityDirectly();
      }
    }
  }

  /// Hàm phụ trợ check mạng thật sự
  Future<bool> _checkConnectivityDirectly() async {
    // 1. Kiểm tra xem có đang kết nối phần cứng nào không (Wifi/3G/Ethernet)
    // Khai báo rõ kiểu List<ConnectivityResult> để tránh nhầm lẫn
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    // SỬA LỖI Ở ĐÂY: Dùng .contains() để kiểm tra trong danh sách
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
    final storage = GetStorage();
    final authService = Get.find<AuthService>();
    final isFirstTime = storage.read('IS_FIRST_TIME') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authService.isLoggedIn.value) {
      // SỬA Ở ĐÂY: Đá user vào trang Main (Chứa thanh Navigation)
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
