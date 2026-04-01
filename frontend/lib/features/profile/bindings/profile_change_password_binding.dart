import 'package:frontend/features/profile/controllers/profile_change_password_controller.dart';
import 'package:get/get.dart';

class ProfileChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileChangePasswordController>(
        () => ProfileChangePasswordController());
  }
}
