import '../../../core/network/api_client.dart';
import '../models/habit_model.dart';

class HabitService {
  final ApiClient _apiClient;

  HabitService(this._apiClient);

  Future<Habit> createHabit({
    required String title,
    String? description,
    required String category,
    int duration = 1,
    bool isMicro = false,
    bool isRoutine = false,
    String? routineType,
    String? preferredTime,
    String? triggerType,
    String? environment,
    int difficultyLevel = 1,
  }) async {
    final response = await _apiClient.post('/habits/create', data: {
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'isMicro': isMicro,
      'isRoutine': isRoutine,
      'routineType': routineType,
      'preferredTime': preferredTime,
      'triggerType': triggerType,
      'environment': environment,
      'difficultyLevel': difficultyLevel,
    });
    return Habit.fromJson(response.data);
  }

  Future<List<Habit>> getTodayHabits() async {
    // NOTE: Do NOT catch errors here. Let them propagate so the
    // FutureProvider shows an error state instead of an empty list.
    // Silent swallowing was causing habits to "disappear" after token expiry.
    final response = await _apiClient.get('/habits/today');
    return (response.data as List).map((h) => Habit.fromJson(h)).toList();
  }

  Future<HabitLog> completeHabit({
    required String habitId,
    int? moodBefore,
    int? moodAfter,
    String? note,
    int? actualDuration,
    DateTime? forDate,
  }) async {
    final response = await _apiClient.post('/habits/complete', data: {
      'habitId': habitId,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'note': note,
      'actualDuration': actualDuration,
      'forDate': forDate?.toIso8601String(),
    });
    return HabitLog.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> getRecommendations(String goal) async {
    try {
      final response = await _apiClient.get('/habits/recommendations', queryParameters: {'goal': goal});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getInsights() async {
    try {
      final response = await _apiClient.get('/habits/insights');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Habit>> getHistory({int days = 30}) async {
    final response = await _apiClient.get('/habits/history', queryParameters: {'days': days.toString()});
    return (response.data as List).map((h) => Habit.fromJson(h)).toList();
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await _apiClient.get('/habits/analytics');
    return response.data as Map<String, dynamic>;
  }
}
