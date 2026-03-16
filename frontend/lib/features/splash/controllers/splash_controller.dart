import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/services/auth_service.dart';

class SplashController extends GetxController {
  // 1. State variables
  final RxDouble progress = 0.0.obs;

  // 2. Lifecycle methods
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // 3. Private methods
  /// Điều phối các tác vụ khởi tạo hệ thống
  Future<void> _initializeApp() async {
    // Phân chia các Task để thanh tiến trình chạy đều
    final List<Future<void> Function()> tasks = [
      _loadSystemSettings,
      _initCoreServices, // Khởi tạo các Service nặng (như AuthService)
      _checkUserAuthentication, // Đọc data, kết nối mạng...
    ];

    for (int i = 0; i < tasks.length; i++) {
      await tasks[i](); // Chạy từng tác vụ
      progress.value =
          (i + 1) / tasks.length; // Cập nhật progress 33% -> 66% -> 100%
    }

    // Đợi một chút để người dùng thấy thanh load đầy 100%
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToNextScreen();
  }

  /// TÁC VỤ 1: Nạp cài đặt (Theme, Ngôn ngữ...)
  Future<void> _loadSystemSettings() async {
    // TODO: Viết logic nạp cấu hình hệ thống tại đây
    await Future.delayed(const Duration(milliseconds: 400)); // Fake delay
  }

  /// TÁC VỤ 2: Khởi tạo các Service Toàn cục
  Future<void> _initCoreServices() async {
    // Nạp AuthService vào RAM ở đây.
    // Hàm init() của AuthService sẽ tự động đọc Két sắt (Secure Storage)
    // và set biến isLoggedIn thành true nếu có mật khẩu.
    await Get.putAsync(() => AuthService().init());

    // Nếu sau này bạn có SyncService (Đồng bộ offline), bạn cũng Get.putAsync ở đây
  }

  /// TÁC VỤ 3: Tải dữ liệu bộ đệm (Nếu cần)
  Future<void> _checkUserAuthentication() async {
    // Do AuthService đã tự check ở trên rồi, ở đây ta có thể dùng để gọi API
    // lấy thông báo mới nhất, hoặc tải trước danh sách Categories...
    await Future.delayed(const Duration(milliseconds: 400)); // Fake delay
  }

  /// ĐIỀU HƯỚNG CUỐI CÙNG
  void _navigateToNextScreen() {
    final storage = GetStorage();
    final authService = Get.find<AuthService>();

    // Đọc cờ xem người dùng đã xem màn hình Onboarding chưa (Mặc định là true nếu chưa có)
    final isFirstTime = storage.read('IS_FIRST_TIME') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authService.isLoggedIn.value) {
      // 2. Nếu không phải lần đầu, và trong két sắt có tài khoản -> Vào thẳng Home
      Get.offAllNamed(AppRoutes.home);
    } else {
      // 3. Nếu chưa đăng nhập -> Vào trang Login
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
