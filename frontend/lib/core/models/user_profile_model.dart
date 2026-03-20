class UserProfileModel {
  final String userId;
  final String authUserId;
  final String email;
  final String fullName;
  final String activeStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.userId,
    required this.authUserId,
    required this.email,
    required this.fullName,
    required this.activeStatus,
    this.createdAt,
    this.updatedAt,
  });

  // Chuyển từ JSON (Backend) sang Model (Flutter)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] ?? '',
      authUserId: json['auth_user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Unknown User',
      activeStatus: json['active_status'] ?? 'inactive', // Map thêm trường này
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Chuyển từ Model sang JSON (để gửi lên Backend nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'auth_user_id': authUserId,
      'email': email,
      'full_name': fullName,
      'active_status': activeStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Hàm giúp copyModel và thay đổi một vài giá trị (rất hữu ích cho GetX/Bloc)
  UserProfileModel copyWith({
    String? userId,
    String? authUserId,
    String? email,
    String? fullName,
    String? activeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      authUserId: authUserId ?? this.authUserId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      activeStatus: activeStatus ?? this.activeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
