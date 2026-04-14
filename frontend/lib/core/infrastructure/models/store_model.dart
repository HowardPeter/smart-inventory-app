import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class StoreModel {
  final String storeId;
  final String name;
  final String? inviteCode;
  final String? address;
  final String role;
  final String activeStatus;

  StoreModel({
    required this.storeId,
    required this.name,
    this.inviteCode,
    this.address,
    required this.role,
    required this.activeStatus,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? 'Unknown Store',
      inviteCode: json['inviteCode'] ?? TTexts.plsGenerateNewCode.tr,
      address: json['address'],
      role: json['role'] ?? 'staff',
      activeStatus: json['activeStatus'] ?? 'active',
    );
  }

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
