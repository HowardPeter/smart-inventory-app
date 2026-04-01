import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/all_products_controller.dart';

class AllProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllProductsController());
  }
}