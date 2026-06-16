import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network_constants.dart';

class ApiClient {
  late Dio dio;
  
  String get baseUrl => NetworkConstants.baseUrl;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 45),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add logging for debugging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('🌐 [API] $obj'),
    ));

    // Consolidated Refresh Token Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final path = e.requestOptions.path;
        if (e.response?.statusCode == 401 && !path.contains('/auth/login')) {
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');

          if (refreshToken != null) {
            try {
              // Create a dedicated Dio instance for refresh to avoid interceptor recursion
              final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
              final response = await refreshDio.post(
                '/auth/refresh',
                options: Options(headers: {
                  'Authorization': 'Bearer $refreshToken',
                }),
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final newAccessToken = response.data['access_token'];
                final newRefreshToken = response.data['refresh_token'];

                // Persist new tokens
                await prefs.setString('access_token', newAccessToken);
                await prefs.setString('refresh_token', newRefreshToken);

                // Update original request headers and retry
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );

                final retryResponse = await dio.request(
                  e.requestOptions.path,
                  data: e.requestOptions.data is FormData ? null : e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                  options: opts,
                );

                if (e.requestOptions.data is FormData) {
                  debugPrint('⚠️ [API] Cannot retry FormData requests. Skipping.');
                  return handler.next(e);
                }

                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              // Refresh failed, clear tokens and force login
              await prefs.remove('access_token');
              await prefs.remove('refresh_token');
              // Optional: Trigger a global logout event here via a stream or provider
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  // Helper methods for common HTTP verbs
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.delete(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> uploadFile(String path, File file, {Map<String, dynamic>? queryParameters}) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    return await dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
