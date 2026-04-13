class HomeAdjustmentModel {
  final String id;
  final String productName;
  final int difference;
  final DateTime time;

  bool get isPositive => difference > 0;

  HomeAdjustmentModel({
    required this.id,
    required this.productName,
    required this.difference,
    required this.time,
  });
}
