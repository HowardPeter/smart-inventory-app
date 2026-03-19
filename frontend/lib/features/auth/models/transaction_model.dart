class TransactionModel {
  final String transactionId;
  final double totalAmount;
  final String transactionType;
  final DateTime createdAt;

  TransactionModel({
    required this.transactionId,
    required this.totalAmount,
    required this.transactionType,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] ?? '',
      totalAmount: double.parse(json['total_amount'].toString()),
      transactionType: json['transaction_type'] ?? 'sale',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
