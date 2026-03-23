import 'package:supabase_flutter/supabase_flutter.dart';

class TokenUtils {
  // Ngăn chặn việc khởi tạo class này thành object
  TokenUtils._();

  static String? get accessToken =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  static String? get refreshToken =>
      Supabase.instance.client.auth.currentSession?.refreshToken;

  // Kiểm tra xem phiên đăng nhập đã hết hạn hoặc bị null chưa
  static bool get isSessionExpired {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null || session.isExpired;
  }
}
