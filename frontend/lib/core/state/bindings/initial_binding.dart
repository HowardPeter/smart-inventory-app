import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient(), permanent: true);
    Get.put(BarcodeScannerController(), permanent: true);
  }
}
