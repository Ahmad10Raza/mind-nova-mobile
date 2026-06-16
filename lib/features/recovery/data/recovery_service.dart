import '../../../core/network/api_client.dart';
import '../models/recovery_model.dart';

class RecoveryService {
  final ApiClient _apiClient;

  RecoveryService(this._apiClient);

  Future<List<RecoverySession>> getSessions({String? category}) async {
    final response = await _apiClient.get(
      '/recovery/sessions',
      queryParameters: category != null ? {'category': category} : null,
    );
    return (response.data as List).map((e) => RecoverySession.fromJson(e)).toList();
  }

  Future<RecoveryLog> startSession(String sessionId, {int? mood, int? stress}) async {
    final response = await _apiClient.post(
      '/recovery/start',
      data: {
        'sessionId': sessionId,
        'beforeMood': mood,
        'beforeStress': stress,
      },
    );
    return RecoveryLog.fromJson(response.data);
  }

  Future<RecoveryLog> completeSession(String logId, {int? mood, int? stress, int? duration}) async {
    final response = await _apiClient.post(
      '/recovery/complete',
      data: {
        'logId': logId,
        'afterMood': mood,
        'afterStress': stress,
        'durationSeconds': duration,
      },
    );
    return RecoveryLog.fromJson(response.data);
  }

  Future<RecoveryScore> getScore() async {
    final response = await _apiClient.get('/recovery/score');
    return RecoveryScore.fromJson(response.data);
  }

  Future<RecoveryRecommendation> getRecommendation({String? category}) async {
    final response = await _apiClient.get(
      '/recovery/recommendation',
      queryParameters: category != null ? {'category': category} : null,
    );
    return RecoveryRecommendation.fromJson(response.data);
  }

  Future<List<RecoveryLog>> getHistory() async {
    final response = await _apiClient.get('/recovery/history');
    return (response.data as List).map((e) => RecoveryLog.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getInsights() async {
    final response = await _apiClient.get('/recovery/insights');
    return response.data;
  }

  Future<void> recordFeedback(String stageType, bool isPositive) async {
    await _apiClient.post(
      '/recovery/feedback',
      data: {
        'stageType': stageType,
        'isPositive': isPositive,
      },
    );
  }
}
