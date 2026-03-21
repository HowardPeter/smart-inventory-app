import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/features/auth/controllers/forgot_password_controller.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(authProvider: Get.find<AuthProvider>()),
    );
  }
}
