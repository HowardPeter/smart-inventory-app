// lib/features/workspace/providers/workspace_provider.dart
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class WorkspaceProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<StoreModel>> getMyStores() async {
    try {
      final response = await _apiClient.get('/api/stores');
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // --- BỔ SUNG HÀM CREATE STORE ---
  Future<StoreModel> createStore(Map<String, dynamic> storeData) async {
    try {
      // Gọi POST endpoint '/' như định nghĩa trong store.route.ts của bạn
      final response = await _apiClient.post('/api/stores', data: storeData);

      // Lấy data trả về từ Backend
      final dynamic data = response.data['data'] ?? response.data;
      return StoreModel.fromJson(data);
    } catch (e) {
      rethrow; // Ném lỗi ra để Controller dùng TExceptions xử lý
    }
  }
}
