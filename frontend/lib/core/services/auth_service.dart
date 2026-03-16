import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/routes/app_routes.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _secureStorage = const FlutterSecureStorage();

  // Biến theo dõi trạng thái đăng nhập toàn cục
  final RxBool isLoggedIn = false.obs;

  /// Khởi chạy khi mở App để kiểm tra trạng thái
  Future<AuthService> init() async {
    final savedEmail = _storage.read('REMEMBER_EMAIL');
    final savedPassword = await _secureStorage.read(key: 'REMEMBER_PASSWORD');

    // Nếu có mật khẩu trong két sắt -> Đã đăng nhập
    if (savedEmail != null && savedPassword != null) {
      isLoggedIn.value = true;
    }
    return this;
  }

  /// Hàm lưu thông tin (Controller sẽ gọi hàm này khi Login thành công)
  Future<void> saveUserLogin(
    String email,
    String password,
    bool rememberMe,
  ) async {
    isLoggedIn.value = true; // Bật cờ đăng nhập

    if (rememberMe) {
      _storage.write('REMEMBER_EMAIL', email);
      await _secureStorage.write(key: 'REMEMBER_PASSWORD', value: password);
    } else {
      // Nếu không tick Remember Me, ta chỉ cho vào App nhưng không lưu ổ cứng
      _storage.remove('REMEMBER_EMAIL');
      await _secureStorage.delete(key: 'REMEMBER_PASSWORD');
    }
  }

  /// Hàm Đăng xuất
  Future<void> logout() async {
    // Xóa sạch bộ nhớ
    await _storage.remove('REMEMBER_EMAIL');
    await _secureStorage.delete(key: 'REMEMBER_PASSWORD');

    isLoggedIn.value = false;

    // Đá về trang Login
    Get.offAllNamed(AppRoutes.login);
  }
}
