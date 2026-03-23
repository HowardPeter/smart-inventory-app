class StoreModel {
  final String storeId;
  final String name;
  final String? address;
  final String role;
  final String activeStatus;

  StoreModel({
    required this.storeId,
    required this.name,
    this.address,
    required this.role,
    required this.activeStatus,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? 'Unknown Store',
      address: json['address'],
      role: json['role'] ?? 'staff',
      activeStatus: json['activeStatus'] ?? 'active',
    );
  }

  // ---> THÊM PHƯƠNG THỨC NÀY VÀO <---
  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'name': name,
      'address': address,
      'role': role,
      'activeStatus': activeStatus,
    };
  }
}
