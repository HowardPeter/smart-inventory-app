import 'package:frontend/features/inventory/controllers/inventory_insight_controller.dart';
import 'package:get/get.dart';

class InventoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryInsightController>(() => InventoryInsightController());
  }
}
