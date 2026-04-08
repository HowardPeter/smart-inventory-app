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

  Map<String, dynamic> toJson() => {
        'product_package_id': productPackageId,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}
