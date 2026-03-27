import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';

class InventoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryDetailController>(() => InventoryDetailController());
  }
}
