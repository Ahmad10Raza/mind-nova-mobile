import '../models/grounding_model.dart';
import '../../../core/network/api_client.dart';

class GroundingService {
  final ApiClient _apiClient;
  GroundingService(this._apiClient);

  Future<GroundingDashboard> getDashboard() async {
    final response = await _apiClient.get('/grounding/dashboard');
    return GroundingDashboard.fromJson(response.data);
  }

  Future<GroundingSession> logSession({
    required GroundingExerciseType exerciseType,
    SafePlaceEnvironment? environment,
    required int durationSecs,
    int? calmBefore,
    int? calmAfter,
    bool? wouldRepeat,
    bool completedFull = true,
  }) async {
    final response = await _apiClient.post('/grounding/session', data: {
      'exerciseType': exerciseType.id,
      if (environment != null) 'environment': environment.id,
      'durationSecs': durationSecs,
      if (calmBefore != null) 'calmBefore': calmBefore,
      if (calmAfter != null) 'calmAfter': calmAfter,
      if (wouldRepeat != null) 'wouldRepeat': wouldRepeat,
      'completedFull': completedFull,
    });
    return GroundingSession.fromJson(response.data);
  }

  Future<GroundingSession> submitCalmRating({
    required String sessionId,
    required int calmBefore,
    required int calmAfter,
    bool? wouldRepeat,
  }) async {
    final response = await _apiClient.post('/grounding/calm-rating/$sessionId', data: {
      'calmBefore': calmBefore,
      'calmAfter': calmAfter,
      if (wouldRepeat != null) 'wouldRepeat': wouldRepeat,
    });
    return GroundingSession.fromJson(response.data);
  }

  Future<List<GroundingSession>> getHistory({int skip = 0, int take = 20}) async {
    final response = await _apiClient.get('/grounding/history', queryParameters: {'skip': skip, 'take': take});
    return (response.data as List).map((e) => GroundingSession.fromJson(e)).toList();
  }

  Future<GroundingAnalyticsModel> getAnalytics() async {
    final response = await _apiClient.get('/grounding/analytics');
    return GroundingAnalyticsModel.fromJson(response.data);
  }

  Future<void> saveFavoriteEnvironment(SafePlaceEnvironment env) async {
    await _apiClient.post('/grounding/favorite-environment', data: {'environment': env.id});
  }

  Future<List<dynamic>> getFavorites() async {
    final response = await _apiClient.get('/grounding/favorites');
    return response.data as List;
  }
}
