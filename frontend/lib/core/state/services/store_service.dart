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

  final RxString currentStoreId = ''.obs;
  final RxString currentStoreName = ''.obs;

  Future<StoreService> init() async {
    // Lúc app vừa mở lên, móc ổ cứng ra xem trước đây có lưu email không
    isLoggedIn.value = storage.read('IS_LOGGED_IN') ?? false;
    currentUserEmail.value = storage.read('USER_EMAIL') ?? '';

    // Xem có data của store chưa
    currentStoreId.value = storage.read('STORE_ID') ?? '';
    currentStoreName.value = storage.read('STORE_NAME') ?? '';
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
      await storage.write('USER_EMAIL', email);
    }

    // GHI VÀO RAM (Để giao diện Home hiện ngay lập tức)
    isLoggedIn.value = true;
    currentUserEmail.value = email;
  }

  // Hàm lưu dữ liệu chọn cửa hàng
  Future<void> saveSelectedStore(String storeId, String storeName) async {
    await storage.write('STORE_ID', storeId);
    await storage.write('STORE_NAME', storeName);

    currentStoreId.value = storeId;
    currentStoreName.value = storeName;
  }

  Future<void> clearAuthData() async {
    await storage.remove('IS_LOGGED_IN');
    await storage.remove('USER_EMAIL');

    await storage.remove('STORE_ID');
    await storage.remove('STORE_NAME');

    isLoggedIn.value = false;
    currentUserEmail.value = '';
  }
}
