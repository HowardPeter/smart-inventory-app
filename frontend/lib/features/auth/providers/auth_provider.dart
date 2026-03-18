import 'package:flutter/foundation.dart';
import 'package:frontend/core/models/user_profile_model.dart';
import 'package:frontend/core/network/app_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/login_request_model.dart';

class AuthProvider {
  // Bắt buộc phải truyền ApiClient vào khi khởi tạo
  final ApiClient apiClient;
  AuthProvider({required this.apiClient});

  // 1. CẬP NHẬT BẢN 7.2.0: Sử dụng GoogleSignIn.instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Đưa Client ID ra một biến riêng cho gọn
  final String _serverClientId =
      '312359689211-1iqfd8ccf58fp2n242tg4bi207in4ts7.apps.googleusercontent.com';

  /// Hàm đăng nhập Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // 2. CẬP NHẬT BẢN 7.2.0: Phải initialize trước khi dùng
      await _googleSignIn.initialize(serverClientId: _serverClientId);

      // Đảm bảo user được chọn lại account
      await _googleSignIn.signOut();

      // 3. CẬP NHẬT BẢN 7.2.0: Sử dụng authenticate() thay vì signIn()
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      return account;
    } catch (e) {
      debugPrint('Lỗi Google Sign-In: $e');
      rethrow;
    }
  }

  Future<UserProfileModel> loginWithEmail(LoginRequestModel request) async {
    // --- BẮT ĐẦU ĐOẠN CODE TEST ---
    // Giả lập chờ mạng 1.5 giây để xem vòng xoay Loading
    await Future.delayed(const Duration(milliseconds: 1500));

    if (request.email == "admin@gmail.com" && request.password == "123456") {
      // Trả về data đúng cấu trúc bảng UserProfile trong database của bạn
      return UserProfileModel.fromJson({
        "user_id": "u-123456-789",
        "auth_user_id": "auth-abc-xyz",
        "email": "admin@gmail.com",
        "full_name": "Admin Group 21",
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      });
    } else {
      // Trả về lỗi nếu nhập sai
      throw Exception("Email or password was wrong. Please try again!");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // 1. Giả lập gọi API mất 2 giây (để UI hiện vòng xoay Loading)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Fake Logic: KIỂM TRA ĐÍCH DANH EMAIL
    if (email == "admin@gmail.com") {
      // Nếu đúng là admin@gmail.com -> Không làm gì cả (Hàm kết thúc thành công)
      return;
    } else {
      // Nếu nhập bất cứ email nào khác -> Ném ra lỗi
      throw Exception("Mail not exists.");
    }
  }
}
