import 'package:frontend/core/infrastructure/models/product_package_model.dart';

// 1. Model cho Item trong 1 Transaction
class TransactionDetailModel {
  final String? productPackageId;
  final int quantity;
  final double unitPrice;

  // Thông tin thêm để hiển thị UI (không gửi lên API tạo)
  final ProductPackageModel? packageInfo;
  final int currentStock;
  final int reorderThreshold;

  TransactionDetailModel({
    this.productPackageId,
    required this.quantity,
    required this.unitPrice,
    this.packageInfo,
    this.currentStock = 0,
    this.reorderThreshold = 0,
  });

  // 🟢 HÀM MỚI BỔ SUNG: Parse từ JSON thành Object
  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      // Bắt cả 2 trường hợp camelCase và snake_case
      productPackageId: json['productPackageId'] ?? json['product_package_id'],
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ??
              json['unit_price']?.toString() ??
              '0') ??
          0.0,

      // Parse object lồng nếu có trả về từ API (ví dụ tên package)
      packageInfo: json['productPackage'] != null
          ? ProductPackageModel.fromJson(json['productPackage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_package_id': productPackageId,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}
