import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:get/get.dart';

class ProfileEditStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditStoreController>(() => ProfileEditStoreController());
  }
}
