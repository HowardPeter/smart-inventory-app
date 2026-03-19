import 'package:supabase_flutter/supabase_flutter.dart';

// gọi accessToken khi cần
// ví dụ: final token = AuthHelper.accessToken;
class AuthHelper {
  static String? get accessToken =>
      Supabase.instance.client.auth.currentSession?.accessToken;
}
