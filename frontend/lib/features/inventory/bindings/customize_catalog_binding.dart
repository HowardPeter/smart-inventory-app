import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/customize_catalog_controller.dart';

class CustomizeCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizeCatalogController>(() => CustomizeCatalogController());
  }
}
