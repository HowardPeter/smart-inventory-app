import 'package:get/get.dart';
import 'package:frontend/core/network/app_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Khởi tạo ApiClient và ép nó sống vĩnh viễn (permanent: true)
    Get.put(ApiClient(), permanent: true);
  }
}
