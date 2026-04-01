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
      userId: json['userId'] ?? '',
      authUserId: json['authUserId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? 'Unknown User',
      activeStatus: json['activeStatus'] ?? 'inactive', // Map thêm trường này
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  get profilePicture => null;

  // Chuyển từ Model sang JSON (để gửi lên Backend nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'authUserId': authUserId,
      'email': email,
      'fullName': fullName,
      'activeStatus': activeStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
