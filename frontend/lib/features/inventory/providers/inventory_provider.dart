import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';

class InventoryProvider {
  final _apiClient = ApiClient();

  // 1. Lấy danh sách danh mục
  Future<List<CategoryModel>> getCategories() async {
    final listData = await _apiClient
        .getList('/api/categories', queryParameters: {'limit': 100});
    return listData.map((json) => CategoryModel.fromJson(json)).toList();
  }

  // 2. Lấy danh sách sản phẩm
  Future<List<ProductModel>> getProducts() async {
    final listData = await _apiClient
        .getList('/api/products', queryParameters: {'limit': 100});
    return listData.map((json) => ProductModel.fromJson(json)).toList();
  }

  // 3. Lấy danh sách tồn kho
  Future<List<InventoryModel>> getInventories() async {
    final listData = await _apiClient
        .getList('/api/inventories', queryParameters: {'limit': 100});
    return listData.map((json) => InventoryModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getProductDetail(String productId) async {
    final response = await _apiClient.get('/api/products/$productId');

    // Bóc lớp "data" theo chuẩn API của bạn
    if (response.data != null && response.data['data'] != null) {
      return response.data['data'] as Map<String, dynamic>;
    }

    throw Exception('No data found');
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final listData = await _apiClient.getList('/api/products',
        queryParameters: {'categoryId': categoryId, 'limit': 100});
    return listData.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductPackageModel>> getPackagesByProduct(
      String productId) async {
    final listData = await _apiClient.getList(
        '/api/products/$productId/packages',
        queryParameters: {'limit': 100});
    return listData.map((json) => ProductPackageModel.fromJson(json)).toList();
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/categories', data: data);

    if (response.data != null && response.data['data'] != null) {
      return CategoryModel.fromJson(response.data['data']);
    } else if (response.data != null) {
      return CategoryModel.fromJson(response.data);
    }

    throw Exception('Failed to create category');
  }

  // Cập nhật danh mục
  Future<void> updateCategory(
      String categoryId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/categories/$categoryId', data: data);
  }

  // Xóa danh mục
  Future<void> deleteCategory(String categoryId) async {
    await _apiClient.delete('/api/categories/$categoryId');
  }

  // 1. Tạo Sản phẩm gốc
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/products', data: data);
    return ProductModel.fromJson(response.data['data'] ?? response.data);
  }

  // 2. Cập nhật Sản phẩm gốc
  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/products/$productId', data: data);
  }

  // 3. Tạo Package cho Sản phẩm
  Future<Map<String, dynamic>> createProductPackage(
      String productId, Map<String, dynamic> data) async {
    final response =
        await _apiClient.post('/api/products/$productId/packages', data: data);
    return response.data['data'] ?? response.data;
  }

  // 4. Tạo Inventory 
  Future<void> createInventory(Map<String, dynamic> data) async {
    await _apiClient.post('/api/inventories', data: data);
  }
}
