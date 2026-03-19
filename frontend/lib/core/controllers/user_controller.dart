import 'package:frontend/core/models/user_profile_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final Rx<UserProfileModel?> currentUser = Rx<UserProfileModel?>(null);
  final RxBool isLoading = false.obs;

  /// Hàm giả lập lấy dữ liệu dựa trên UserProfileModel (Mapping chính xác từ Prisma)
  Future<void> fetchUserProfile(String email) async {
    try {
      isLoading.value = true;

      // Giả lập delay mạng để test Loading Shimmer/Spinner
      await Future.delayed(const Duration(milliseconds: 1500));

      // Fake data khớp chính xác với UserProfileModel và Prisma Schema của bạn
      currentUser.value = UserProfileModel(
        userId: 'u-123',
        authUserId: 'auth-abc',
        email: email, // Sử dụng email truyền vào
        fullName: 'Phát Nguyễn',
        role: 'manager', // Role chuẩn: manager hoặc staff
        createdAt: DateTime.parse("2026-01-20T08:00:00Z"),
        updatedAt: DateTime.now(), // Thêm updatedAt cho đầy đủ model
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi hệ thống',
        'Không thể tải hồ sơ người dùng. Vui lòng thử lại sau.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Xóa dữ liệu khi người dùng đăng xuất
  void clearUserData() {
    currentUser.value = null;
  }
}
