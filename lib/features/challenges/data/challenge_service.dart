import '../../../core/network/api_client.dart';
import '../models/challenge_model.dart';

class ChallengeService {
  final ApiClient _apiClient;

  ChallengeService(this._apiClient);

  Future<List<Challenge>> getChallenges() async {
    try {
      final response = await _apiClient.get('/challenges');
      return (response.data as List)
          .map((c) => Challenge.fromJson(c))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Challenge> getChallengeDetail(String id) async {
    final response = await _apiClient.get('/challenges/$id');
    return Challenge.fromJson(response.data);
  }

  Future<UserChallenge> startChallenge({
    required String challengeId,
    String? preferredTime,
    bool reminderEnabled = true,
    String? reminderTime,
  }) async {
    final response = await _apiClient.post('/challenges/start', data: {
      'challengeId': challengeId,
      'preferredTime': preferredTime,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
    });
    return UserChallenge.fromJson(response.data);
  }

  Future<UserChallenge?> getActiveChallenge() async {
    try {
      final response = await _apiClient.get('/challenges/active');
      if (response.data == null || response.data == '') return null;
      return UserChallenge.fromJson(response.data);
    } catch (e, st) {
      print('🔴 getActiveChallenge error: $e\n$st');
      return null;
    }
  }

  Future<UserChallenge> completeDay({
    required String userChallengeId,
    required int dayNumber,
    required int tasksCompleted,
    required int totalTasks,
  }) async {
    final response = await _apiClient.post('/challenges/complete-day', data: {
      'userChallengeId': userChallengeId,
      'dayNumber': dayNumber,
      'tasksCompleted': tasksCompleted,
      'totalTasks': totalTasks,
    });
    return UserChallenge.fromJson(response.data);
  }

  Future<void> abandonChallenge({
    required String userChallengeId,
    bool pause = false,
    String? reason,
  }) async {
    await _apiClient.post('/challenges/abandon', data: {
      'userChallengeId': userChallengeId,
      'pause': pause,
      'reason': reason,
    });
  }
}
