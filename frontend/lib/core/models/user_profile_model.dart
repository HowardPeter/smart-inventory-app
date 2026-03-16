/// Model ánh xạ chính xác với bảng UserProfile trong Prisma Schema
class UserProfileModel {
  UserProfileModel({
    required this.userId,
    required this.authUserId,
    required this.email,
    required this.fullName,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String authUserId;
  final String email;
  final String fullName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      // Ánh xạ chính xác key JSON từ Backend (chữ thường, có dấu gạch dưới như schema)
      userId: json['user_id'] ?? '',
      authUserId: json['auth_user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Unknown User',

      // Xử lý an toàn cho kiểu DateTime
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
