import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreService extends GetxService {
  final storage = GetStorage();

  // Chỉ quản lý thông tin Không gian làm việc (Store)
  final RxString currentStoreId = ''.obs;
  final RxString currentStoreName = ''.obs;
  final RxString currentRole = 'staff'.obs;
  final RxString currentInviteCode = ''.obs; 

  Future<StoreService> init() async {
    // Đọc từ ổ cứng xem lần trước đang xem dở cửa hàng nào
    currentStoreId.value = storage.read('STORE_ID') ?? '';
    currentStoreName.value = storage.read('STORE_NAME') ?? '';
    currentRole.value = storage.read('STORE_ROLE') ?? 'staff';
    currentInviteCode.value =
        storage.read('STORE_INVITE_CODE') ?? ''; 
    return this;
  }

  // Lưu dữ liệu khi chọn một Không gian làm việc
  Future<void> saveSelectedStore(
      String storeId, String storeName, String role, String inviteCode) async {
    // Thêm tham số inviteCode
    // 1. Lưu vào ổ cứng (Storage)
    await storage.write('STORE_ID', storeId);
    await storage.write('STORE_NAME', storeName);
    await storage.write('STORE_ROLE', role);
    await storage.write('STORE_INVITE_CODE', inviteCode); 

    // 2. Lưu vào RAM để UI tự động đổi
    currentStoreId.value = storeId;
    currentStoreName.value = storeName;
    currentRole.value = role;
    currentInviteCode.value = inviteCode; // Bổ sung
  }

  // Hàm chỉ cập nhật riêng lẻ Invite Code (Dùng khi bấm "Tạo mã mới")
  Future<void> updateInviteCode(String newCode) async {
    await storage.write('STORE_INVITE_CODE', newCode);
    currentInviteCode.value = newCode;
  }

  // Xóa dữ liệu Không gian làm việc (Dùng khi đăng xuất)
  Future<void> clearWorkspaceData() async {
    await storage.remove('STORE_ID');
    await storage.remove('STORE_NAME');
    await storage.remove('STORE_ROLE');
    await storage.remove('STORE_INVITE_CODE');

    currentStoreId.value = '';
    currentStoreName.value = '';
    currentRole.value = 'staff';
    currentInviteCode.value = '';
  }
}
