import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class ReportProvider {
  final _apiClient = ApiClient();

  Future<List<TransactionModel>> getTransactions(
      {Map<String, dynamic>? queryParams}) async {
    // Gọi API lấy danh sách transaction (giả định route là /api/transactions)
    final listData = await _apiClient.getList(
      '/api/transactions',
      queryParameters: queryParams ??
          {'limit': 100, 'sortBy': 'createdAt', 'sortOrder': 'desc'},
    );

    return listData.map((json) => TransactionModel.fromJson(json)).toList();
  }
}
