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

  Map<String, dynamic> toJson() => {
        if (note != null) 'note': note,
        'total_price': totalPrice,
        'type': type,
        'status': status,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
