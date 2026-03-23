import 'package:frontend/features/workspace/controllers/add_members_controller.dart';
import 'package:get/get.dart';

class AddMembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMembersController>(() => AddMembersController());
  }
}
