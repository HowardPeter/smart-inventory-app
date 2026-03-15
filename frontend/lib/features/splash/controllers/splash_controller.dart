import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';

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
    // Danh sách các tác vụ cần load. Sau này bạn chỉ cần viết logic thật vào các hàm này.
    final List<Future<void> Function()> tasks = [
      _loadSystemSettings,
      _initLocalDatabase,
      _checkUserAuthentication,
    ];

    for (int i = 0; i < tasks.length; i++) {
      await tasks[i](); // Chạy từng tác vụ
      progress.value =
          (i + 1) / tasks.length; // Cập nhật progress theo số lượng task
    }

    // Đợi một chút để người dùng thấy thanh load đầy 100%
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToNextScreen();
  }

  /// TÁC VỤ 1: Nạp cài đặt (Theme, Ngôn ngữ...)
  Future<void> _loadSystemSettings() async {
    // TODO: Viết logic nạp SharedPreferences tại đây
    await Future.delayed(const Duration(seconds: 1)); // Fake delay
  }

  /// TÁC VỤ 2: Khởi tạo Database cục bộ
  Future<void> _initLocalDatabase() async {
    // TODO: Viết logic nạp dữ liệu offline/cache tại đây
    await Future.delayed(const Duration(seconds: 1)); // Fake delay
  }

  /// TÁC VỤ 3: Kiểm tra trạng thái đăng nhập
  Future<void> _checkUserAuthentication() async {
    // TODO: Gọi AuthRepository để kiểm tra Token thực tế
    await Future.delayed(const Duration(seconds: 1)); // Fake delay
  }

  void _navigateToNextScreen() {
    // Điều hướng dựa trên trạng thái (Ví dụ: mặc định sang Onboarding)
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
