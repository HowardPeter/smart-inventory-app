import 'package:frontend/features/profile/controllers/profile_assigns_role_controller.dart';
import 'package:get/get.dart';

class ProfileAssignsRoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileAssignsRoleController>(
        () => ProfileAssignsRoleController());
  }
}
