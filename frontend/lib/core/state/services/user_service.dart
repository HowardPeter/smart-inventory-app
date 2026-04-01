import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';

class UserService extends GetxService {
  final UserProfileProvider _profileProvider = UserProfileProvider();

  // Biến observable lưu trữ thông tin user hiện tại.
  // Dùng Rxn (hoặc Rx<UserProfileModel?>) để cho phép giá trị null khi chưa đăng nhập.
  final Rx<UserProfileModel?> currentUser = Rx<UserProfileModel?>(null);

  // Biến loading để UI (ví dụ màn hình splash) có thể lắng nghe
  final RxBool isLoading = false.obs;

  Object? get stores => null;

  Future<UserService> init() async {
    return this;
  }

  // Hàm này gọi sau khi login thành công HOẶC khi app mở lên có remember me
  Future<bool> fetchAndSaveProfile() async {
    isLoading.value = true;
    try {
      // Gọi provider để lấy data từ backend
      final profile = await _profileProvider.fetchMyProfile();
      currentUser.value = profile; // Lưu vào RAM
      return true;
    } catch (e) {
      // Nếu lỗi (ví dụ token hết hạn), clear state
      clearUser();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Xóa data trên RAM khi logout
  void clearUser() {
    currentUser.value = null;
  }
}
