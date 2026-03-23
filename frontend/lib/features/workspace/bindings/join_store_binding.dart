import 'package:frontend/features/workspace/controllers/join_store_controller.dart';
import 'package:get/get.dart';

class JoinStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinStoreController>(() => JoinStoreController());
  }
}
