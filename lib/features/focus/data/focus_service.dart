import '../models/focus_model.dart';
import '../../../core/network/api_client.dart';

class FocusService {
  final ApiClient _apiClient;

  FocusService(this._apiClient);

  Future<FocusSession> startSession({
    required FocusMode mode,
    required int durationMinutes,
    String? goal,
    String? moodBefore,
    String? selectedAudio,
  }) async {
    final response = await _apiClient.post('/focus/start', data: {
      'mode': mode.toJson(),
      'durationMinutes': durationMinutes,
      if (goal != null) 'goal': goal,
      if (moodBefore != null) 'moodBefore': moodBefore,
      if (selectedAudio != null) 'selectedAudio': selectedAudio,
    });
    return FocusSession.fromJson(response.data);
  }

  Future<FocusSession> endSession(String id, FocusSession session) async {
    final response = await _apiClient.post('/focus/end/$id', data: session.toJson());
    return FocusSession.fromJson(response.data);
  }

  Future<FocusStats> getStats() async {
    final response = await _apiClient.get('/focus/stats');
    return FocusStats.fromJson(response.data);
  }

  Future<List<FocusSession>> getHistory() async {
    final response = await _apiClient.get('/focus/history');
    return (response.data as List).map((e) => FocusSession.fromJson(e)).toList();
  }
}
