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
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? 'Unknown Category',
      description: json['description'],
      storeId: json['store_id'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
      'store_id': storeId,
      'is_default': isDefault,
    };
  }
}
