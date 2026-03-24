import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:frontend/features/auth/providers/auth_provider.dart';

class ProfileController extends GetxController {
  // Lấy thẳng UserService đã nạp trên RAM từ lúc Splash khởi động
  final userService = Get.find<UserService>();
  final supabase = Supabase.instance.client;

  Future<void> executeLogout() async {
    try {
      // 1. Hiện loading UI đồng bộ với toàn App
      FullScreenLoaderUtils.openLoadingDialog('Đang đăng xuất...');

      // 2. Gọi hàm logout thực sự của Supabase (Hủy phiên làm việc trên server)
      await supabase.auth.signOut();
      // Đăng xuất Google để lần sau hiện lại popup chọn tài khoản
      await GoogleSignIn.instance.signOut();

      // 3. Dọn ổ cứng (Xóa token, email, trạng thái login)
      await Get.find<AuthService>().clearAuthData();

      // 4. QUAN TRỌNG: Dọn sạch ID Cửa hàng cũ (Xóa cache StoreService)
      await Get.find<StoreService>().clearWorkspaceData();

      // 5. Dọn RAM (Xóa thông tin UserProfile đang hiển thị)
      userService.clearUser();

      // 6. Tắt loading
      FullScreenLoaderUtils.stopLoading();

      // 7. Đá văng về màn Login, xóa sạch mọi lịch sử trang
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      // Hiển thị lỗi bằng chuẩn TSnackbarsWidget của App thay vì Get.snackbar mặc định
      TSnackbarsWidget.error(title: 'Lỗi đăng xuất', message: e.toString());
    }
  }
}
