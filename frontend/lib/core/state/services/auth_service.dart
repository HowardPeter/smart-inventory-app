import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final storage = GetStorage();

  // 1. Biến quản lý trạng thái đăng nhập
  final RxBool isLoggedIn = false.obs;
  final RxString currentUserEmail = ''.obs;

  Future<AuthService> init() async {
    // Đọc ổ cứng xem trước đó đã đăng nhập chưa
    isLoggedIn.value = storage.read('IS_LOGGED_IN') ?? false;
    currentUserEmail.value = storage.read('USER_EMAIL') ?? '';
    return this;
  }

  // Lưu trạng thái khi đăng nhập thành công
  Future<void> saveUserLogin(
      String email, String password, bool rememberMe) async {
    if (rememberMe) {
      await storage.write('IS_LOGGED_IN', true);
      await storage.write('USER_EMAIL', email);
    }

    // Cập nhật lên RAM để UI phản hồi ngay lập tức
    isLoggedIn.value = true;
    currentUserEmail.value = email;
  }

  // Xóa sạch dữ liệu khi Đăng xuất
  Future<void> clearAuthData() async {
    await storage.remove('IS_LOGGED_IN');
    await storage.remove('USER_EMAIL');

    isLoggedIn.value = false;
    currentUserEmail.value = '';
  }
}
