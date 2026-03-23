class ProductPackageModel {
  final String productPackageId;
  final String displayName;
  final double importPrice;
  final double sellingPrice;

  ProductPackageModel({
    required this.productPackageId,
    required this.displayName,
    required this.importPrice,
    required this.sellingPrice,
  });

  factory ProductPackageModel.fromJson(Map<String, dynamic> json) {
    return ProductPackageModel(
      productPackageId: json['product_package_id'] ?? '',
      displayName: json['display_name'] ?? 'Unknown Product',
      importPrice:
          double.tryParse(json['import_price']?.toString() ?? '0') ?? 0.0,
      sellingPrice:
          double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
