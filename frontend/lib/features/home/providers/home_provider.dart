import 'package:flutter/foundation.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart'; 

class HomeProvider {
  final _apiClient = ApiClient();

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final now = DateTime.now();
      // Lấy từ tháng trước đến tháng sau (y hệt Report) để chắc chắn lấy đủ ngày ở biên múi giờ
      final startDateStr =
          DayFormatterUtils.formatApiDate(DateTime(now.year, now.month - 1, 1));
      final endDateStr =
          DayFormatterUtils.formatApiDate(DateTime(now.year, now.month + 1, 0));

      final response =
          await _apiClient.get('/api/transactions', queryParameters: {
        'limit': 100,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        'startDate': startDateStr,
        'endDate': endDateStr,
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

      return listData.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Lỗi getTransactions (Home): $e");
      return [];
    }
  }

  Future<List<InventoryModel>> getLowStockInventories() async {
    try {
      final response =
          await _apiClient.get('/api/inventories/low-stock', queryParameters: {
        'limit': 10,
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
      debugPrint("Lỗi getLowStockInventories (Home): $e");
      return [];
    }
  }

  Future<int> getTotalStockQuantity() async {
    try {
      final response =
          await _apiClient.get('/api/inventories', queryParameters: {
        'limit': 1000,
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

      final inventories =
          listData.map((json) => InventoryModel.fromJson(json)).toList();
      return inventories.fold<int>(0, (int sum, item) => sum + item.quantity);
    } catch (e) {
      debugPrint("Lỗi getTotalStockQuantity (Home): $e");
      return 0;
    }
  }
}
