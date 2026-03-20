// Model cho chi tiết từng sản phẩm trong một giao dịch
class HomeTransactionDetailModel {
  final String productPackageId;
  final int quantity;
  final double unitPrice;

  HomeTransactionDetailModel({
    required this.productPackageId,
    required this.quantity,
    required this.unitPrice,
  });

  factory HomeTransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return HomeTransactionDetailModel(
      productPackageId: json['product_package_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
    );
  }
}

// Model cho một giao dịch đầy đủ (bao gồm danh sách chi tiết)
class HomeInventoryTransactionModel {
  final String transactionId;
  final String type;
  final double totalPrice;
  final DateTime createdAt;
  final List<HomeTransactionDetailModel> details;

  HomeInventoryTransactionModel({
    required this.transactionId,
    required this.type,
    required this.totalPrice,
    required this.createdAt,
    required this.details,
  });

  factory HomeInventoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return HomeInventoryTransactionModel(
      transactionId: json['transaction_id'] ?? '',
      type: json['type'] ?? '',
      totalPrice: double.parse(json['total_price']?.toString() ?? '0'),
      createdAt: DateTime.parse(json['created_at']),
      details: (json['transaction_details'] as List<dynamic>? ?? [])
          .map((e) =>
              HomeTransactionDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
