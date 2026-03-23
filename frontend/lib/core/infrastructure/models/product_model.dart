class ProductModel {
  final String productId;
  final String name;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? brand;
  final String storeId;
  final String categoryId;
  final String activeStatus;

  ProductModel({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    required this.storeId,
    required this.categoryId,
    required this.activeStatus,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      imageUrl: json['image_url'],
      // Xử lý an toàn cho kiểu DateTime từ String của Supabase
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      brand: json['brand'],
      storeId: json['store_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      activeStatus: json['active_status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'brand': brand,
      'store_id': storeId,
      'category_id': categoryId,
      'active_status': activeStatus,
    };
  }
}
