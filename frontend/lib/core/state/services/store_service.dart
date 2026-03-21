// file: lib/core/services/auth_service.dart

import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreService extends GetxService {
  final storage = GetStorage();
  late final AuthProvider authProvider;

  // 1. Biến quản lý trạng thái
  final RxBool isLoggedIn = false.obs;

  // 2. TẠO BIẾN LƯU EMAIL (Để UI tự động lắng nghe)
  final RxString currentUserEmail = ''.obs;

  Future<StoreService> init() async {
    // Lúc app vừa mở lên, móc ổ cứng ra xem trước đây có lưu email không
    isLoggedIn.value = storage.read('IS_LOGGED_IN') ?? false;
    currentUserEmail.value = storage.read('USER_EMAIL') ?? '';
    return this;
  }

  // Hàm lưu dữ liệu khi Login
  Future<void> saveUserLogin(
    String email,
    String password,
    bool rememberMe,
  ) async {
    if (rememberMe) {
      // GHI VÀO Ổ CỨNG (Để lần sau tắt app mở lại vẫn còn)
      await storage.write('IS_LOGGED_IN', true);
      await storage.write('USER_EMAIL', email); // Nhãn bắt buộc là 'USER_EMAIL'
    }

    // GHI VÀO RAM (Để giao diện Home hiện ngay lập tức)
    isLoggedIn.value = true;
    currentUserEmail.value = email;
  }

  Future<void> clearAuthData() async {
    await storage.remove('IS_LOGGED_IN');
    await storage.remove('USER_EMAIL');

    isLoggedIn.value = false;
    currentUserEmail.value = '';
  }
}
