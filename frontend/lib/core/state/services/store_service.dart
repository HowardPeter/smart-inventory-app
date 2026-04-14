import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreService extends GetxService {
  final storage = GetStorage();

  // Chỉ quản lý thông tin Không gian làm việc
  final RxString currentStoreId = ''.obs;
  final RxString currentStoreName = ''.obs;
  final RxString currentRole = 'staff'.obs;

  final RxString currentStoreAddress = ''.obs;

  Future<StoreService> init() async {
    // Đọc từ ổ cứng xem lần trước đang xem dở cửa hàng nào
    currentStoreId.value = storage.read('STORE_ID') ?? '';
    currentStoreName.value = storage.read('STORE_NAME') ?? '';
    currentRole.value = storage.read('STORE_ROLE') ?? 'staff';
    currentStoreAddress.value = storage.read('STORE_ADDRESS') ?? '';

    return this;
  }

  // Lưu dữ liệu khi chọn một Không gian làm việc
  Future<void> saveSelectedStore(
    String storeId,
    String storeName,
    String role,
  ) async {
    // 1. Lưu vào ổ cứng (Storage)
    await storage.write('STORE_ID', storeId);
    await storage.write('STORE_NAME', storeName);
    await storage.write('STORE_ROLE', role);

    // 2. Lưu vào RAM để UI tự động đổi
    currentStoreId.value = storeId;
    currentStoreName.value = storeName;
    currentRole.value = role;
  }

  // Dùng khi đã có address và muốn lưu riêng
  Future<void> saveStoreAddress(String address) async {
    await storage.write('STORE_ADDRESS', address);
    currentStoreAddress.value = address;
  }

  // Dùng khi edit store xong, cập nhật nhanh name + address
  Future<void> updateStoreInfo({
    String? name,
    String? address,
  }) async {
    if (name != null) {
      await storage.write('STORE_NAME', name);
      currentStoreName.value = name;
    }

    if (address != null) {
      await storage.write('STORE_ADDRESS', address);
      currentStoreAddress.value = address;
    }
  }

  // Xóa dữ liệu Không gian làm việc (Dùng khi đăng xuất)
  Future<void> clearWorkspaceData() async {
    await storage.remove('STORE_ID');
    await storage.remove('STORE_NAME');
    await storage.remove('STORE_ROLE');
    await storage.remove('STORE_ADDRESS');

    currentStoreId.value = '';
    currentStoreName.value = '';
    currentRole.value = 'staff';
    currentStoreAddress.value = '';
  }
}
