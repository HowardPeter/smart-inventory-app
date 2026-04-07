import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';

class TransactionModel {
  final String? transactionId;
  final DateTime? createdAt;
  final String? note;
  final double totalPrice;
  final String? userId;
  final String type; // 'INBOUND', 'OUTBOUND', 'ADJUSTMENT'
  final String status; // 'COMPLETED', 'PENDING', 'CANCELLED'
  final List<TransactionDetailModel> items;

  TransactionModel({
    this.transactionId,
    this.createdAt,
    this.note,
    required this.totalPrice,
    this.userId,
    required this.type,
    required this.status,
    required this.items,
  });

  // 🟢 HÀM MỚI BỔ SUNG: Parse từ JSON thành Object
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] ?? json['transaction_id'],

      // Parse DateTime an toàn
      createdAt: (json['createdAt'] != null || json['created_at'] != null)
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'])
          : null,

      note: json['note'],

      // Parse double an toàn (đề phòng API trả về String hoặc Int)
      totalPrice: double.tryParse(json['totalPrice']?.toString() ??
              json['total_price']?.toString() ??
              '0') ??
          0.0,

      userId: json['userId'] ?? json['user_id'],
      type: json['type'] ?? 'UNKNOWN',
      status: json['status'] ?? 'UNKNOWN',

      // Lặp qua mảng items (nếu có) và gọi fromJson của TransactionDetailModel
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) =>
                  TransactionDetailModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (note != null) 'note': note,
        'total_price': totalPrice,
        'type': type,
        'status': status,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
