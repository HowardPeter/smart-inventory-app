import 'package:frontend/core/controllers/barcode_scanner_controller.dart';
import 'package:frontend/core/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/network/app_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Khởi tạo ApiClient và ép nó sống vĩnh viễn (permanent: true)
    Get.put(ApiClient(), permanent: true);
    Get.put(UserController(), permanent: true);
    Get.put(BarcodeScannerController(), permanent: true);
  }
}
