// file: lib/core/services/auth_service.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreService extends GetxService {
  final storage = GetStorage();

  // Chỉ quản lý thông tin Không gian làm việc (Store)
  final RxString currentStoreId = ''.obs;
  final RxString currentStoreName = ''.obs;
  final RxString currentRole = 'staff'.obs; // Lưu thêm chức vụ

  Future<StoreService> init() async {
    // Đọc từ ổ cứng xem lần trước đang xem dở cửa hàng nào
    currentStoreId.value = storage.read('STORE_ID') ?? '';
    currentStoreName.value = storage.read('STORE_NAME') ?? '';
    currentRole.value = storage.read('STORE_ROLE') ?? 'staff';
    return this;
  }

  // Lưu dữ liệu khi chọn một Không gian làm việc
  Future<void> saveSelectedStore(
      String storeId, String storeName, String role) async {
    // 1. Lưu vào ổ cứng (Storage)
    await storage.write('STORE_ID', storeId);
    await storage.write('STORE_NAME', storeName);
    await storage.write('STORE_ROLE', role);

    // 2. Lưu vào RAM để UI tự động đổi
    currentStoreId.value = storeId;
    currentStoreName.value = storeName;
    currentRole.value = role;
  }

  // Xóa dữ liệu Không gian làm việc (Dùng khi đăng xuất)
  Future<void> clearWorkspaceData() async {
    await storage.remove('STORE_ID');
    await storage.remove('STORE_NAME');
    await storage.remove('STORE_ROLE');

    currentStoreId.value = '';
    currentStoreName.value = '';
    currentRole.value = 'staff';
  }
}
