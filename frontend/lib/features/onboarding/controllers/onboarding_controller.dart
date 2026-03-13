import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  // Biến quản lý trang hiện tại (mặc định là 0 - trang đầu tiên)
  final currentPage = 0.obs;

  // Hàm xử lý khi bấm nút "Tiếp tục"
  void nextPage() {
    // Tạm thời test: Bấm nút thì chuyển thẳng qua trang Login
    Get.offAllNamed(AppRoutes.login);
  }

  // Hàm xử lý khi bấm nút "Bỏ qua"
  void skipPage() {
    Get.offAllNamed(AppRoutes.login);
  }
}