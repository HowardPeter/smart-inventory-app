import 'product_package_model.dart';

class InventoryModel {
  final String inventoryId;
  final int quantity;
  final int reorderThreshold;
  final ProductPackageModel? productPackage;

  InventoryModel({
    required this.inventoryId,
    required this.quantity,
    required this.reorderThreshold,
    this.productPackage,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json['inventory_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      reorderThreshold: json['reorder_threshold'] ?? 0,
      productPackage: json['product_package'] != null
          ? ProductPackageModel.fromJson(json['product_package'])
          : null,
    );
  }
}
