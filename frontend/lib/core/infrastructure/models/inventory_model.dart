import 'product_package_model.dart';

class InventoryModel {
  final String inventoryId;
  final int quantity;
  final int reorderThreshold;
  final int lastCount;
  final DateTime updatedAt;
  final String productPackageId;
  final String activeStatus;
  final ProductPackageModel? productPackage;

  InventoryModel({
    required this.inventoryId,
    required this.quantity,
    required this.reorderThreshold,
    required this.lastCount,
    required this.updatedAt,
    required this.productPackageId,
    required this.activeStatus,
    this.productPackage,
  });
  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json['inventoryId'] ?? '',
      quantity: json['quantity'] ?? 0,
      reorderThreshold: json['reorderThreshold'] ?? 0,
      lastCount: json['lastCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      activeStatus: json['activeStatus'] ?? 'active',
      productPackageId: json['productPackageId'] ?? '',
      productPackage: json['productPackage'] != null
          ? ProductPackageModel.fromJson(json['productPackage'])
          : null,
    );
  }
}
