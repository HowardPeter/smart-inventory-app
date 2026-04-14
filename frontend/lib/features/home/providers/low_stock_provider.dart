import 'package:flutter/foundation.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class LowStockProvider {
  final _apiClient = ApiClient();

  Future<List<InventoryModel>> getLowStockInventories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response =
          await _apiClient.get('/api/inventories/low-stock', queryParameters: {
        'page': page,
        'limit': limit,
        'sortBy': 'quantity',
        'sortOrder': 'asc',
      });

      final responseData = response.data['data'];
      List<dynamic> listData = [];

      if (responseData != null) {
        if (responseData is Map && responseData.containsKey('items')) {
          listData = responseData['items'];
        } else if (responseData is List) {
          listData = responseData;
        }
      } else if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && response.data.containsKey('items')) {
        listData = response.data['items'];
      }

      return listData.map((json) => InventoryModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Lỗi getLowStockInventories (Provider): $e");
      return [];
    }
  }
  
}
