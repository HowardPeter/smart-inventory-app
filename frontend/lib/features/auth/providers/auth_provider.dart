import 'package:frontend/core/models/user_profile_model.dart';
import 'package:frontend/core/network/app_client.dart';
import '../models/login_request_model.dart';

class AuthProvider {
  // Bắt buộc phải truyền ApiClient vào khi khởi tạo
  final ApiClient apiClient;
  AuthProvider({required this.apiClient});

  Future<UserProfileModel> loginWithEmail(LoginRequestModel request) async {
    // --- BẮT ĐẦU ĐOẠN CODE TEST ---
    // Giả lập chờ mạng 1.5 giây để xem vòng xoay Loading
    await Future.delayed(const Duration(milliseconds: 1500));

    if (request.email == "admin@gmail.com" && request.password == "123456") {
      // Trả về data đúng cấu trúc bảng UserProfile trong Prisma của bạn
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

    // Future<UserProfileModel> loginWithEmail(LoginRequestModel request) async {
    //   try {
    //     // Dùng apiClient.post thay vì dio.post
    //     final response = await apiClient.post(
    //       '/auth/login',
    //       data: request.toJson(),
    //     );

    //     if (response.statusCode == 200 || response.statusCode == 201) {
    //       return UserProfileModel.fromJson(response.data['data']);
    //     } else {
    //       throw Exception('Lỗi máy chủ!');
    //     }
    //   } catch (e) {
    //     throw Exception('Đã xảy ra lỗi: $e');
    //   }
    // }
  }
}
