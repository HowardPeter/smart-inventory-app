import 'package:get/get.dart';
import '../controllers/create_store_controller.dart';

class CreateStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateStoreController>(() => CreateStoreController());
  }
}
