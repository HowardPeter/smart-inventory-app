import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/category_form_controller.dart';

class CategoryFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryFormController());
  }
}
