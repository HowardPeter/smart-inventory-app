import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl, // Dùng baseUrl của bạn
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          //Lấy token từ supabase
          final session = Supabase.instance.client.auth.currentSession;
          final token = session?.accessToken;
          // debugPrint("DEBUG TOKEN: $token");

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final storeId = GetStorage().read('STORE_ID');
          if (storeId != null && storeId.toString().isNotEmpty) {
            options.headers['x-store-id'] = storeId;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) => handler.next(e),
      ),
    );
  }

  // Cung cấp các hàm gọi API cơ bản
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }

  Future<List<dynamic>> getList(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await get(path, queryParameters: queryParameters);
    final dataField = response.data['data'];

    if (dataField == null) return [];
    if (dataField is List) return dataField;
    if (dataField is Map) return dataField['items'] ?? dataField['data'] ?? [];
    return [];
  }
}
