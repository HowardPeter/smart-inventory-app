import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:get/get.dart';

class ProductCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductCatalogController());
  }
}
