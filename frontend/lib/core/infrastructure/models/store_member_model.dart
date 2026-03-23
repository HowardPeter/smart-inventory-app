class StoreMemberModel {
  final String id;
  final String storeId;
  final String userId;
  final String name;
  final String email;
  final String role;
  final String joinedAt;
  final bool isCurrentUser;

  StoreMemberModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.isCurrentUser = false,
  });

  factory StoreMemberModel.fromJson(Map<String, dynamic> json,
      {String currentUserId = ''}) {
    final userMap = json['user'] ?? json;
    final uId = json['userId'] ?? userMap['id'] ?? '';

    return StoreMemberModel(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      userId: uId,
      name: userMap['fullName'] ?? userMap['name'] ?? 'Unknown User',
      email: userMap['email'] ?? 'No email',
      role: json['role'] ?? 'staff',
      joinedAt: json['createdAt'] ?? '',
      isCurrentUser: uId == currentUserId,
    );
  }
}
