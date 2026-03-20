import 'package:flutter/foundation.dart';
import 'package:frontend/core/models/user_profile_model.dart';
import 'package:frontend/core/network/app_client.dart';

class UserProfileProvider {
  final _apiClient = ApiClient();

  Future<void> createUserProfile() async {
    try {
      await _apiClient.post(
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

  Future<UserProfileModel> fetchMyProfile() async {
    try {
      // Gọi API GET /auth/me (Endpoint này cần trùng với Route ở Backend)
      final response = await _apiClient.get('/auth/me');
      // print("Dữ liệu từ Server: ${response.data}");
      final Map<String, dynamic> data = response.data['data'];

      return UserProfileModel.fromJson(data);
    } catch (e) {
      rethrow; // Đẩy lỗi về cho Controller xử lý
    }
  }
}
