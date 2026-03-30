import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

class CustomizeCatalogController extends GetxController {
  final InventoryController _inventoryController =
      Get.find<InventoryController>();

  // Danh sách đang thao tác trên màn hình Customize
  final RxList<String> currentOrder = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Lấy danh sách hiện tại từ InventoryController
    currentOrder
        .assignAll(_inventoryController.categoryStats.map((c) => c.name));
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String item = currentOrder.removeAt(oldIndex);
    currentOrder.insert(newIndex, item);
  }

  void saveOrder() {
    _inventoryController.saveCustomOrder(currentOrder);
    Get.back();
  }
}
