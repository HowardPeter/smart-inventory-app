import 'package:get/get.dart';
import '../controllers/store_selection_controller.dart';

class StoreSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreSelectionController>(() => StoreSelectionController());
  }
}
