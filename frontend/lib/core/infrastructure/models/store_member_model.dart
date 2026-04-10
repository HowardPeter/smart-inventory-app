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

  // --- BỔ SUNG HÀM COPYWITH ---
  StoreMemberModel copyWith({
    String? id,
    String? storeId,
    String? userId,
    String? name,
    String? email,
    String? role,
    String? joinedAt,
    bool? isCurrentUser,
  }) {
    return StoreMemberModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
