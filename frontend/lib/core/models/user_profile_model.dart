/// Model ánh xạ chính xác với bảng UserProfile trong Prisma Schema
class UserProfileModel {
  UserProfileModel({
    required this.userId,
    required this.authUserId,
    required this.email,
    required this.fullName,
    required this.role, // Bắt buộc phải có
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String authUserId;
  final String email;
  final String fullName;
  final String role; // Không được để null
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] ?? '',
      authUserId: json['auth_user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Unknown User',

      // FIX LỖI TẠI ĐÂY: Nếu key 'role' bị null hoặc thiếu, gán mặc định là 'staff'
      role: json['role']?.toString() ?? 'staff',

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
