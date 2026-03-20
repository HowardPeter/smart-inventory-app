import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/app_client.dart';

class UserProfileProvider {
  final apiClient = ApiClient();

  Future<void> createUserProfile() async {
    try {
      await apiClient.post(
        '/auth/me/profile',
        data: {
          "fullName": "user@${DateTime.now().millisecondsSinceEpoch}",
        },
      );

      debugPrint("Tạo profile thành công");
    } catch (e) {
      debugPrint("Lỗi tạo profile: $e");
    }
  }
}
