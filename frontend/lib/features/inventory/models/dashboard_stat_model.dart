class CategoryStatModel {
  final String name;
  final int count;

  CategoryStatModel({required this.name, required this.count});
}

class DistributionModel {
  final String name;
  final int value;
  final int max;

  DistributionModel(
      {required this.name, required this.value, required this.max});
}
