import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class TransactionProvider {
  final _apiClient = ApiClient();

  Future<bool> createTransaction(TransactionModel data) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

 

  // 🟢 MOCK: LẤY CÁC GIAO DỊCH NHẬP KHO (INBOUND) CŨ LÀM LÔ HÀNG (FIFO)
  Future<List<TransactionModel>> getInboundTransactionsForPackage(
      String packageId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Test với Coca Carton (hoặc Coca Can)
    if (packageId == '22222222-2222-4222-a222-222222222010' ||
        packageId == '22222222-2222-4222-a222-222222222009') {
      return [
        TransactionModel(
          transactionId: "tx-inbound-001",
          createdAt: DateTime.parse("2026-01-10 08:00:00"),
          type: "INBOUND",
          status: "COMPLETED",
          totalPrice: 0,
          items: [
            TransactionDetailModel(
                productPackageId: packageId, quantity: 5, unitPrice: 6.0)
          ],
        ),
        TransactionModel(
          transactionId: "tx-inbound-002",
          createdAt: DateTime.parse("2026-01-15 09:30:00"),
          type: "INBOUND",
          status: "COMPLETED",
          totalPrice: 0,
          items: [
            TransactionDetailModel(
                productPackageId: packageId, quantity: 10, unitPrice: 6.0)
          ],
        ),
        TransactionModel(
          transactionId: "tx-inbound-003",
          createdAt: DateTime.parse("2026-02-01 10:00:00"),
          note: "Lô này đã hết hàng để test UI",
          type: "INBOUND",
          status: "COMPLETED",
          totalPrice: 0,
          items: [
            TransactionDetailModel(
                productPackageId: packageId, quantity: 0, unitPrice: 6.0)
          ], // 🟢 Lô hết hàng
        ),
        TransactionModel(
          transactionId: "tx-inbound-004",
          createdAt: DateTime.parse("2026-03-26 16:30:00"),
          type: "INBOUND",
          status: "COMPLETED",
          totalPrice: 0,
          items: [
            TransactionDetailModel(
                productPackageId: packageId, quantity: 20, unitPrice: 6.0)
          ],
        ),
      ];
    }
    return [];
  }

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
          if (note != null) 'note': note
        });
  }

  Future<void> updateProductPackage(
      String productPackageId, Map<String, dynamic> data) async {
    await _apiClient.patch('/api/product-packages/$productPackageId',
        data: data);
  }
}
