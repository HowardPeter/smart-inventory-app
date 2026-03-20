class UserProfileModel {
  final String userId;
  final String authUserId;
  final String email;
  final String fullName;
  final String activeStatus;

  UserProfileModel({
    required this.userId,
    required this.authUserId,
    required this.email,
    required this.fullName,
    required this.activeStatus,
  });

  // Chuyển từ JSON (từ API) sang Object
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] ?? '',
      authUserId: json['authUserId'] ?? '',
      email: json['email'] ?? '',
      // CHÚ Ý: Phải khớp 100% với key 'fullName' từ JSON của server
      fullName: json['fullName'] ?? 'Unknown User',
      activeStatus: json['activeStatus'] ?? '',
    );
  }
}
