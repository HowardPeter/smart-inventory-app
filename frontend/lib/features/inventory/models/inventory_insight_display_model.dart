import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';

class InventoryInsightDisplayModel {
  final InventoryModel inventory;
  final ProductModel? product; // Sẽ chứa ảnh sản phẩm ở đây

  InventoryInsightDisplayModel({required this.inventory, this.product});
}
