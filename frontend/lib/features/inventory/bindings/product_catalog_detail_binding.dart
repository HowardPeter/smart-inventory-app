import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';

class ProductCatalogDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductCatalogDetailController());
  }
}
