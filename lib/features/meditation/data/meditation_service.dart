import '../domain/meditation_model.dart';
import '../../../core/network/api_client.dart';

class MeditationService {
  final ApiClient _apiClient;

  MeditationService(this._apiClient);

  Future<MeditationDashboardStats> getDashboardStats() async {
    final response = await _apiClient.get('/meditation/dashboard');
    return MeditationDashboardStats.fromJson(response.data);
  }

  Future<List<MeditationContent>> getMasterCatalog({String? category}) async {
    final response = await _apiClient.get(
      '/meditation/catalog',
      queryParameters: category != null ? {'category': category} : null,
    );
    return (response.data as List).map((json) => MeditationContent.fromJson(json)).toList();
  }

  Future<List<MeditationContent>> getRecommended() async {
    final response = await _apiClient.get('/meditation/recommended');
    return (response.data as List).map((json) => MeditationContent.fromJson(json)).toList();
  }

  Future<List<String>> getCategories() async {
    final response = await _apiClient.get('/meditation/categories');
    return List<String>.from(response.data);
  }
  Future<List<MeditationSession>> getRecentSessions({int limit = 20}) async {
    try {
      final response = await _apiClient.get('/meditation/history', queryParameters: {'take': limit.toString()});
      return (response.data as List).map((json) => MeditationSession.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> completeSession({
    required String contentId,
    required int durationSecs,
    required int calmBefore,
    required int calmAfter,
  }) async {
    try {
      await _apiClient.post(
        '/meditation/session/complete/$contentId',
        data: {
          'durationSecs': durationSecs,
          'calmBefore': calmBefore,
          'calmAfter': calmAfter,
        },
      );
    } catch (e) {
      // Ignore if offline
    }
  }
}
