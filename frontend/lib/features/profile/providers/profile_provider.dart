import 'package:frontend/core/infrastructure/network/app_client.dart';

class StoreProvider {
  final _apiClient = ApiClient();

  Future<List<dynamic>> getMyStores() async {
    try {
      final response = await _apiClient.get('/api/stores');
      // Bóc tách dữ liệu theo chuẩn ['data'] của backend bạn
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStoreDetail(String storeId) async {
    try {
      final response = await _apiClient.get('/api/stores/$storeId');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Không tìm thấy dữ liệu cửa hàng');
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật thông tin cửa hàng 
  Future<void> updateStore(String storeId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/stores/$storeId', data: data);
  }
}
