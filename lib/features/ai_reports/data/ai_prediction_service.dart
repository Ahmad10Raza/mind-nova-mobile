import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

class AiPredictionService {
  final ApiClient _apiClient;

  AiPredictionService(this._apiClient);

  Future<Map<String, dynamic>> predictModel(String modelType, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(
        '/reports/predict/$modelType',
        data: payload,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to get prediction');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  Future<Map<String, dynamic>> getInsight(String insightId) async {
    try {
      final response = await _apiClient.dio.get('/reports/insight/$insightId');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch insight');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> wakeUp() async {
    try {
      // Hit the new dedicated health check endpoint in the backend
      await _apiClient.dio.get('/reports/health');
    } catch (_) {
      // Ignore errors for warmup
    }
  }
}

final aiPredictionServiceProvider = Provider<AiPredictionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiPredictionService(apiClient);
});
