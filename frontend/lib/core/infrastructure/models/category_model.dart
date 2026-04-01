class CategoryModel {
  final String categoryId;
  final String name;
  final String? description;
  final String storeId;
  final bool isDefault;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.description,
    required this.storeId,
    required this.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? 'Unknown Category',
      description: json['description'],
      storeId: json['storeId'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'storeId': storeId,
      'isDefault': isDefault,
    };
  }
}
