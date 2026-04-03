import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class TransactionProvider {
  final _apiClient = ApiClient();

  // ==========================================
  // 1. CÁC HÀM MOCK (Dùng để test UI)
  // ==========================================

  Future<bool> createTransaction(TransactionModel data) async {
    await Future.delayed(const Duration(seconds: 2)); // Giả lập call mạng
    return true;
  }

  Future<List<Map<String, dynamic>>> getSuggestedPackagesForInbound() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'productPackageId': 'pkg-001',
        'displayName': 'Coca-cola (330ml)',
        'importPrice': 15000.0,
        'imageUrl': 'https://example.com/coca.png',
        'currentStock': 0,
        'reorderThreshold': 20,
      },
      {
        'productPackageId': 'pkg-002',
        'displayName': 'Lay\'s Classic Potato Chips',
        'importPrice': 45000.0,
        'imageUrl': 'https://example.com/lays.png',
        'currentStock': 5,
        'reorderThreshold': 10,
      },
      {
        'productPackageId': 'pkg-003',
        'displayName': 'Oreo Sandwich Cookies',
        'importPrice': 40000.0,
        'imageUrl': 'https://example.com/oreo.png',
        'currentStock': 50,
        'reorderThreshold': 15,
      },
    ];
  }

  // ==========================================
  // 2. CÁC HÀM GỌI API THẬT
  // ==========================================

  Future<Map<String, dynamic>> getInventoryDetailByPackageId(
      String packageId) async {
    try {
      final response =
          await _apiClient.get('/api/inventories/product-packages/$packageId');
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Lỗi khi fetch chi tiết tồn kho: $e');
    }
  }

  // 🟢 THÊM MỚI: API cập nhật số lượng tồn kho (Mượn từ Inventory)
  Future<void> adjustInventory(String packageId,
      {required String type,
      required int quantity,
      String? reason,
      String? note}) async {
    await _apiClient.post(
        '/api/inventories/product-packages/$packageId/adjustments',
        data: {
          'type': type,
          'quantity': quantity,
          if (reason != null) 'reason': reason,
          if (note != null) 'note': note,
        });
  }

  // 🟢 THÊM MỚI: API cập nhật cấu hình Product Package (Giá nhập)
  Future<void> updateProductPackage(
      String productPackageId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/product-packages/$productPackageId',
        data: data);
  }
}
