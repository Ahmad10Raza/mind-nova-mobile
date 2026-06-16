import '../../../core/network/api_client.dart';
import '../models/scoring_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scoringServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScoringService(apiClient);
});

class ScoringService {
  final ApiClient _apiClient;

  ScoringService(this._apiClient);

  /// Calculates the latest CMHI score based on current daily data
  Future<CMHIScore?> calculateLatestScore() async {
    try {
      final response = await _apiClient.post('/scoring/calculate', data: {});
      return CMHIScore.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<CMHIScore>> getScoreHistory() async {
    try {
      final response = await _apiClient.get('/scoring/history');
      final List data = response.data;
      return data.map((json) => CMHIScore.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ScoreExplanation?> getScoreInsight(String scoreId) async {
    try {
      final response = await _apiClient.get('/scoring/insight/$scoreId');
      return ScoreExplanation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getGrowthSummary() async {
    try {
      final response = await _apiClient.get('/scoring/growth');
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
