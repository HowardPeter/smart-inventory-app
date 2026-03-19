import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/app_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  // Bắt buộc phải truyền ApiClient vào khi khởi tạo
  final ApiClient apiClient;
  AuthProvider({required this.apiClient});

  // 1. CẬP NHẬT BẢN 7.2.0: Sử dụng GoogleSignIn.instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final supabase = Supabase.instance.client;

  // Đưa Client ID ra một biến riêng cho gọn
  final String _serverClientId =
      '312359689211-rb6t26nfeqc5pmv268qgj9so090ov7cm.apps.googleusercontent.com';

  /// Hàm đăng nhập Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(serverClientId: _serverClientId);

      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      return account;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('canceled') ||
          errorStr.contains('sign_in_canceled')) {
        debugPrint('Người dùng chủ động đóng popup chọn tài khoản Google.');
        // Trả về null một cách êm đẹp, KHÔNG ném lỗi (rethrow)
        return null;
      }

      // Nếu là lỗi thật sự (mất mạng, sai client ID...) thì mới ném ra ngoài
      debugPrint('Lỗi Google Sign-In thực sự: $e');
      rethrow;
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

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendResetPasswordEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-password',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
