import 'package:flutter/widgets.dart';
import 'package:frontend/core/models/user_profile_model.dart';
import 'package:frontend/features/auth/providers/user_profile_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/services/auth_service.dart';

class HomeController extends GetxController {
  // Khai báo biến này để nhập dữ liệu người dùng khi đăng nhập

  var userProfile = Rxn<UserProfileModel>();

  // Khai báo provider
  final UserProfileProvider userProfileProvider = UserProfileProvider();

  @override
  void onInit() {
    super.onInit();
    getMyProfile();
  }

  Future<void> getMyProfile() async {
    try {
      final profile = await userProfileProvider.fetchMyProfile();
      userProfile.value = profile;
      debugPrint("Data user model: ${userProfile.value!.fullName}");
    } catch (e) {
      debugPrint("Lỗi Không thể lấy thông tin cá nhân: ${e.toString()}");
    }
  }

  void logout() {
    // Gọi thẳng hàm logout của Service
    Get.find<AuthService>().logout();
  }
}
