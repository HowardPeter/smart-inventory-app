import 'package:frontend/core/state/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/user_service.dart';
// import 'package:frontend/features/auth/providers/auth_provider.dart';

class ProfileController extends GetxController {
  // Lấy thẳng UserService đã nạp trên RAM từ lúc Splash khởi động
  final userService = Get.find<UserService>();

  Future<void> executeLogout() async {
    try {
      // 1. Hiện loading (Nếu cần)
      // Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // 2. Gọi hàm logout của Provider/Supabase (Nếu có API)
      // await Get.find<AuthProvider>().logout();

      // 3. Dọn ổ cứng (Local Storage)
      await Get.find<AuthService>().clearAuthData();

      // 4. Dọn RAM (UserService)
      userService.clearUser();

      // 5. Đá văng về màn Login, xóa sạch lịch sử trang
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đăng xuất thất bại: $e');
    }
  }
}
