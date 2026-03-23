// lib/features/workspace/providers/workspace_provider.dart
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
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

  Future<StoreModel> joinStore(String inviteCode) async {
    try {
      final response = await _apiClient.post('/api/stores/join', data: {
        'inviteCode': inviteCode,
      });

      // Lấy thông tin cửa hàng vừa join thành công trả về từ Backend
      final dynamic data = response.data['data'] ?? response.data;
      return StoreModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StoreMemberModel>> getStoreMembers(
      String storeId, String currentUserId) async {
    try {
      // TODO: Bỏ comment 2 dòng dưới khi Backend đã có API /api/stores/:storeId/members
      // final response = await _apiClient.get('/api/stores/$storeId/members');
      // final List<dynamic> data = response.data['data'] ?? response.data;

      // ---- FAKE MOCK DATA (Xóa đoạn này khi có API thật) ----
      await Future.delayed(
          const Duration(seconds: 2)); // Giả lập độ trễ mạng để xem Skeleton

      final List<dynamic> data = [
        {
          "id": "mem_1",
          "storeId": storeId,
          "userId": currentUserId,
          "role": "manager",
          "createdAt": "2026-03-24",
          "user": {
            "id": currentUserId,
            "fullName": "John Boss (You)",
            "email": "john@store.com"
          }
        },
        {
          "id": "mem_2",
          "storeId": storeId,
          "userId": "u_2",
          "role": "staff",
          "createdAt": "2026-03-24",
          "user": {
            "id": "u_2",
            "fullName": "Alex Staff",
            "email": "alex@store.com"
          }
        },
        {
          "id": "mem_3",
          "storeId": storeId,
          "userId": "u_3",
          "role": "manager",
          "createdAt": "2026-03-24",
          "user": {
            "id": "u_3",
            "fullName": "Sarah Co-founder",
            "email": "sarah@store.com"
          }
        }
      ];
      // --------------------------------------------------------

      return data
          .map((json) =>
              StoreMemberModel.fromJson(json, currentUserId: currentUserId))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
