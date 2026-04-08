import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final userService = Get.find<UserService>();
  final _profileProvider = UserProfileProvider();
  final supabase = Supabase.instance.client;
  final apiClient = ApiClient();

  // Observable để UI tự động cập nhật
  var fullName = "".obs;
  var email = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    // Lắng nghe sự thay đổi của currentUser trong UserService (RAM)
    ever(userService.currentUser, (_) => _loadUserProfile());
  }

  /// Nạp thông tin cơ bản từ UserService lên UI
  void _loadUserProfile() {
    final user = userService.currentUser.value;
    if (user != null) {
      // Chỉ lấy Tên và Email để tránh lỗi Undefined getter 'avatarUrl'
      fullName.value = user.fullName;
      email.value = user.email;
    }
  }

  /// Làm mới dữ liệu từ Database (Pull-to-refresh)
  Future<void> refreshProfile() async {
    try {
      // Gọi đúng hàm trong UserProfileProvider của bạn
      final updatedUser = await _profileProvider.fetchMyProfile();
      // Cập nhật lại RAM thông qua UserService
      userService.currentUser.value = updatedUser;
    } catch (e) {
      TSnackbarsWidget.error(
          title: 'Lỗi', message: 'Không thể cập nhật thông tin người dùng');
    }
  }

  /// Logic Đăng xuất toàn diện
  Future<void> executeLogout() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog('Đang đăng xuất...');

      // 1. Hủy session Supabase
      await AuthProvider(apiClient: apiClient).logout();
      // 2. Xóa Token/Session dưới ổ cứng
      await Get.find<AuthService>().clearAuthData();
      // 3. Xóa dữ liệu Workspace/Store
      await Get.find<StoreService>().clearWorkspaceData();
      // 4. Xóa User trên RAM
      userService.clearUser();

      FullScreenLoaderUtils.stopLoading();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(title: 'Lỗi đăng xuất', message: e.toString());
    }
  }

  void goToStoreSelect() {
    if (userService.currentUser.value == null) {
      Get.toNamed(AppRoutes.createStore);
    } else {
      Get.toNamed(AppRoutes.storeSelection);
    }
  }

  void goToEditProfile() => Get.toNamed(AppRoutes.editProfile);
  void goToChangePasswordProfile() => Get.toNamed(AppRoutes.changePassword);
  void goToEditStoreProfile() => Get.toNamed(AppRoutes.editStore);
  void goToAssignsRoleProfile() => Get.toNamed(AppRoutes.assignsRole);
}
// import 'package:frontend/core/infrastructure/network/app_client.dart';
// import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
// import 'package:frontend/core/state/services/auth_service.dart';
// import 'package:frontend/core/state/services/store_service.dart';
// import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
// import 'package:frontend/features/auth/providers/auth_provider.dart';
// import 'package:get/get.dart';
// import 'package:frontend/routes/app_routes.dart';
// import 'package:frontend/core/state/services/user_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfileController extends GetxController {
//   // Lấy thẳng UserService đã nạp trên RAM từ lúc Splash khởi động
//   final userService = Get.find<UserService>();
//   final supabase = Supabase.instance.client;
//   final apiClient = ApiClient();

//   Future<void> executeLogout() async {
//     try {
//       // 1. Hiện loading UI đồng bộ với toàn App
//       FullScreenLoaderUtils.openLoadingDialog('Đang đăng xuất...');

//       // 2. Gọi hàm logout thực sự của Supabase (Hủy phiên làm việc trên server)
//       await AuthProvider(apiClient: apiClient).logout();

//       // 3. Dọn ổ cứng (Xóa token, email, trạng thái login)
//       await Get.find<AuthService>().clearAuthData();

//       // 4. QUAN TRỌNG: Dọn sạch ID Cửa hàng cũ (Xóa cache StoreService)
//       await Get.find<StoreService>().clearWorkspaceData();

//       // 5. Dọn RAM (Xóa thông tin UserProfile đang hiển thị)
//       userService.clearUser();

//       // 6. Tắt loading
//       FullScreenLoaderUtils.stopLoading();

//       // 7. Đá văng về màn Login, xóa sạch mọi lịch sử trang
//       Get.offAllNamed(AppRoutes.login);
//     } catch (e) {
//       FullScreenLoaderUtils.stopLoading();

//       // Hiển thị lỗi bằng chuẩn TSnackbarsWidget của App thay vì Get.snackbar mặc định
//       TSnackbarsWidget.error(title: 'Lỗi đăng xuất', message: e.toString());
//     }
//   }

//   void goToStoreSelect() {
//     final user = userService.currentUser.value;

//     if (user == null) {
//       Get.toNamed(AppRoutes.createStore);
//     } else {
//       Get.toNamed(AppRoutes.storeSelection);
//     }
//   }

//   void goToEditProfile() {
//     Get.toNamed(
//       AppRoutes.editProfile,
//     );
//   }

//   void goToChangePasswordProfile() {
//     Get.toNamed(
//       AppRoutes.changePassword,
//     );
//   }

//   void goToEditStoreProfile() {
//     Get.toNamed(
//       AppRoutes.editStore,
//     );
//   }

//   void goToAssignsRoleProfile() {
//     Get.toNamed(
//       AppRoutes.assignsRole,
//     );
//   }
// }

// import 'package:frontend/core/infrastructure/network/app_client.dart';
// import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
// import 'package:frontend/core/state/services/auth_service.dart';
// import 'package:frontend/core/state/services/store_service.dart';
// import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
// import 'package:frontend/features/auth/providers/auth_provider.dart';
// import 'package:get/get.dart';
// import 'package:frontend/routes/app_routes.dart';
// import 'package:frontend/core/state/services/user_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfileController extends GetxController {
//   // Lấy thẳng UserService đã nạp trên RAM từ lúc Splash khởi động
//   final userService = Get.find<UserService>();
//   final supabase = Supabase.instance.client;
//   final apiClient = ApiClient();

//   Future<void> executeLogout() async {
//     try {
//       // 1. Hiện loading UI đồng bộ với toàn App
//       FullScreenLoaderUtils.openLoadingDialog('Đang đăng xuất...');

//       // 2. Gọi hàm logout thực sự của Supabase (Hủy phiên làm việc trên server)
//       await AuthProvider(apiClient: apiClient).logout();

//       // 3. Dọn ổ cứng (Xóa token, email, trạng thái login)
//       await Get.find<AuthService>().clearAuthData();

//       // 4. QUAN TRỌNG: Dọn sạch ID Cửa hàng cũ (Xóa cache StoreService)
//       await Get.find<StoreService>().clearWorkspaceData();

//       // 5. Dọn RAM (Xóa thông tin UserProfile đang hiển thị)
//       userService.clearUser();

//       // 6. Tắt loading
//       FullScreenLoaderUtils.stopLoading();

//       // 7. Đá văng về màn Login, xóa sạch mọi lịch sử trang
//       Get.offAllNamed(AppRoutes.login);
//     } catch (e) {
//       FullScreenLoaderUtils.stopLoading();

//       // Hiển thị lỗi bằng chuẩn TSnackbarsWidget của App thay vì Get.snackbar mặc định
//       TSnackbarsWidget.error(title: 'Lỗi đăng xuất', message: e.toString());
//     }
//   }

//   void goToStoreSelect() {
//     final user = userService.currentUser.value;

//     if (user == null) {
//       Get.toNamed(AppRoutes.createStore);
//     } else {
//       Get.toNamed(AppRoutes.storeSelection);
//     }
//   }

//   void goToEditProfile() {
//     Get.toNamed(
//       AppRoutes.editProfile,
//     );
//   }

//   void goToChangePasswordProfile() {
//     Get.toNamed(
//       AppRoutes.changePassword,
//     );
//   }

//   void goToEditStoreProfile() {
//     Get.toNamed(
//       AppRoutes.editStore,
//     );
//   }

//   void goToAssignsRoleProfile() {
//     Get.toNamed(
//       AppRoutes.assignsRole,
//     );
//   }
// }
