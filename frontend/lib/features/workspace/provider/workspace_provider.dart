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
}
