import 'package:frontend/core/infrastructure/models/unit_model.dart'; // 🟢 BẮT BUỘC IMPORT

class ProductPackageModel {
  final String productPackageId;
  final String? barcodeValue;
  final String displayName;
  final double importPrice;
  final double sellingPrice;
  final String unitId;
  final String productId;
  final String activeStatus;
  final String? barcodeType;
  final UnitModel? unit; 

  ProductPackageModel({
    required this.productPackageId,
    this.barcodeValue,
    required this.displayName,
    required this.importPrice,
    required this.sellingPrice,
    required this.unitId,
    required this.productId,
    required this.activeStatus,
    this.barcodeType,
    this.unit, 
  });

  factory ProductPackageModel.fromJson(Map<String, dynamic> json) {
    return ProductPackageModel(
      productPackageId: json['productPackageId'] ?? '',
      barcodeValue: json['barcodeValue']?.toString(),
      displayName: json['displayName'] ?? 'Unknown Package',
      importPrice:
          double.tryParse(json['importPrice']?.toString() ?? '0') ?? 0.0,
      sellingPrice:
          double.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0.0,
      unitId: json['unitId'] ?? json['unit']?['unitId'] ?? '',
      productId: json['productId'] ?? json['product']?['productId'] ?? '',
      activeStatus: json['activeStatus'] ?? 'active',
      barcodeType: json['barcodeType'],
      unit: json['unit'] != null ? UnitModel.fromJson(json['unit']) : null,
    );
  }
}
