import 'package:get/get.dart';
import 'package:frontend/core/services/auth_service.dart';

class HomeController extends GetxController {
  void logout() {
    // Gọi thẳng hàm logout của Service
    Get.find<AuthService>().logout();
  }
}
