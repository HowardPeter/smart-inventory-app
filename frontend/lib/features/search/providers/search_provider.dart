import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/features/search/models/search_product_model.dart';

class SearchProvider {
  final _apiClient = ApiClient();

  // Hàm tìm kiếm chính (Giữ nguyên của bạn)
  Future<Map<String, dynamic>> searchProductsByKeyword(String keyword,
      {int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      '/api/search/product-packages',
      queryParameters: {
        'keyword': keyword,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data['data'];
    final items = (data['items'] as List)
        .map((json) => SearchProductModel.fromJson(json))
        .toList();

    return {
      'items': items,
      'totalItems': data['totalItems'] ?? 0,
      'totalPages': data['totalPages'] ?? 1,
    };
  }

  // Hàm gọi API Suggestion (Did you mean)
  Future<List<Map<String, dynamic>>> searchProductsByPrefix(String prefix,
      {int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/api/search/products/prefix',
        queryParameters: {
          'prefix': prefix,
          'limit': limit,
        },
      );
      final data = response.data['data'] ?? response.data;

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
