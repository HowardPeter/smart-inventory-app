import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/features/auth/controllers/verify_email_controller.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

class VerfiEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<VerifyEmailController>(
      () => VerifyEmailController(authProvider: Get.find<AuthProvider>()),
    );
  }
}
