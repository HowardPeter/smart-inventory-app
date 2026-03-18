import 'package:frontend/core/network/app_client.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<LoginController>(
      () => LoginController(authProvider: Get.find<AuthProvider>()),
    );
  }
}
