import '../../../core/network/api_client.dart';
import '../models/mood_model.dart';
import '../models/ai_suggestion_model.dart';
import '../models/mood_question_model.dart';
import '../../ai_reports/models/weekly_report_model.dart';

class MoodService {
  final ApiClient _apiClient;

  MoodService(this._apiClient);

  Future<MoodLog> logMood({
    required String moodName,
    required String category,
    required String intensity,
    required List<String> tags,
    String? notes,
    List<Map<String, String>>? followUpAnswers,
  }) async {
    final response = await _apiClient.post('/moods/log', data: {
      'moodName': moodName,
      'category': category,
      'intensity': intensity,
      'tags': tags,
      'notes': notes,
      'followUpAnswers': followUpAnswers ?? [],
    });
    return MoodLog.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getContextRules({
    required String mood,
    required String intensity,
    List<String> tags = const [],
  }) async {
    final response = await _apiClient.get('/moods/context-rules', queryParameters: {
      'mood': mood,
      'intensity': intensity,
      'tags': tags.join(','),
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> logIntelligent({
    required String mood,
    required String intensity,
    required List<String> tags,
    required List<Map<String, String>> answers,
  }) async {
    final response = await _apiClient.post('/moods/log-intelligent', data: {
      'mood': mood,
      'intensity': intensity,
      'tags': tags,
      'answers': answers,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<String?> getAiComfortMessage(String prompt) async {
    try {
      final response = await _apiClient.post('/moods/ai-comfort', data: {'prompt': prompt});
      return response.data['reply'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<List<MoodQuestion>> getDynamicQuestions(String category, String intensity) async {
    final response = await _apiClient.get('/moods/questions', queryParameters: {
      'category': category,
      'intensity': intensity,
    });
    return (response.data as List).map((q) => MoodQuestion.fromJson(q)).toList();
  }

  Future<List<AiSuggestion>> getAiSuggestions(String logId) async {
    final response = await _apiClient.get('/moods/suggestions', queryParameters: {'logId': logId});
    return (response.data as List).map((s) => AiSuggestion.fromJson(s)).toList();
  }

  Future<void> savePositiveMemory({
    required String logId,
    String? photoUrl,
    String? gratitudeNote,
    List<String>? peopleInvolved,
    List<String>? memoryTags,
  }) async {
    await _apiClient.post('/moods/memory', data: {
      'moodLogId': logId,
      'photoUrl': photoUrl,
      'gratitudeNote': gratitudeNote,
      'peopleInvolved': peopleInvolved ?? [],
      'memoryTags': memoryTags ?? [],
    });
  }

  Future<void> triggerCrisisFlow(String logId, String trigger, String riskLevel, String? details) async {
    await _apiClient.post('/moods/crisis', data: {
      'moodLogId': logId,
      'triggerKeyword': trigger,
      'riskLevel': riskLevel,
      'actionDetails': details,
    });
  }

  Future<void> saveRecoveryFeedback(String logId, String suggestionId, bool didHelp) async {
    await _apiClient.post('/moods/feedback', data: {
      'moodLogId': logId,
      'suggestionId': suggestionId,
      'didHelp': didHelp,
    });
  }

  Future<List<MoodLog>> getMoodHistory() async {
    final response = await _apiClient.get('/moods/history');
    return (response.data as List).map((m) => MoodLog.fromJson(m)).toList();
  }

  // ─── Analytics Methods ──────────────────────────────────────────────────────

  /// Home screen widget data: latest mood + streak + sparkline.
  Future<MoodHomeWidget> getHomeWidget() async {
    try {
      final response = await _apiClient.get('/moods/home-widget');
      return MoodHomeWidget.fromJson(response.data);
    } catch (_) {
      return const MoodHomeWidget(
        hasLogs: false,
        insightMessage: 'Start your first emotional check-in ✨',
        sparkline: [],
        streaks: MoodStreaks(),
      );
    }
  }

  /// Returns computed {score, date, mood, color, emoji}[] from backend.
  Future<List<MoodTrend>> getMoodTrends({int days = 7}) async {
    try {
      final response = await _apiClient.get('/moods/trend', queryParameters: {'days': days});
      return (response.data as List).map((m) => MoodTrend.fromJson(m)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Full analytics summary with delta vs previous period.
  Future<MoodAnalyticsSummary> getAnalyticsSummary({int days = 7}) async {
    try {
      final response = await _apiClient.get('/moods/analytics-summary', queryParameters: {'days': days});
      return MoodAnalyticsSummary.fromJson(response.data);
    } catch (_) {
      return const MoodAnalyticsSummary(hasData: false);
    }
  }

  /// Mood distribution by category: positive/neutral/negative/critical.
  Future<MoodDistribution> getMoodDistribution({int days = 30}) async {
    try {
      final response = await _apiClient.get('/moods/distribution', queryParameters: {'days': days});
      return MoodDistribution.fromJson(response.data);
    } catch (_) {
      return const MoodDistribution(hasData: false);
    }
  }

  /// Trigger analysis with tag frequency and correlations.
  Future<TriggerAnalysis> getTriggerAnalysis({int days = 30}) async {
    try {
      final response = await _apiClient.get('/moods/triggers', queryParameters: {'days': days});
      return TriggerAnalysis.fromJson(response.data);
    } catch (_) {
      return const TriggerAnalysis(hasData: false);
    }
  }

  /// Recovery tool effectiveness statistics.
  Future<RecoveryEffectiveness> getRecoveryEffectiveness({int days = 30}) async {
    try {
      final response = await _apiClient.get('/moods/recovery-effectiveness', queryParameters: {'days': days});
      return RecoveryEffectiveness.fromJson(response.data);
    } catch (_) {
      return const RecoveryEffectiveness(hasData: false);
    }
  }

  /// Rule-based personalized weekly insight strings.
  Future<WeeklyInsights> getWeeklyInsights({int days = 7}) async {
    try {
      final response = await _apiClient.get('/moods/weekly-insights', queryParameters: {'days': days});
      return WeeklyInsights.fromJson(response.data);
    } catch (_) {
      return const WeeklyInsights(insights: []);
    }
  }

  /// Paginated history for the emotional timeline.
  Future<PagedMoodHistory> getMoodHistoryPaged({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get('/moods/history-paged', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return PagedMoodHistory.fromJson(response.data);
  }

  Future<ReflectionHighlightsData> getReflectionHighlights() async {
    try {
      final response = await _apiClient.get('/moods/reflection-highlights');
      return ReflectionHighlightsData.fromJson(response.data);
    } catch (_) {
      return const ReflectionHighlightsData(hasData: false);
    }
  }

  Future<NovaSuggestion> getNovaSuggests() async {
    try {
      final response = await _apiClient.get('/moods/nova-suggests');
      return NovaSuggestion.fromJson(response.data);
    } catch (_) {
      return const NovaSuggestion(title: 'Nova Suggests', body: 'Start your journey by checking in today. Reflection helps build emotional resilience over time.', actionLabel: 'Check In', actionRoute: '/mood-checkin');
    }
  }

  // ─── Legacy / Compatibility ─────────────────────────────────────────────────

  Future<void> syncPendingMoods() async {}

  Future<Map<String, dynamic>> getMoodStreak() async {
    try {
      final response = await _apiClient.get('/moods/streak');
      return response.data;
    } catch (_) {
      return {'currentStreak': 0, 'longestStreak': 0};
    }
  }

  Future<MoodInsights?> getMoodInsights({int days = 7}) async {
    try {
      final response = await _apiClient.get('/moods/insights', queryParameters: {'days': days});
      if (response.data == null || response.data == '') return null;
      return MoodInsights.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<WeeklyReport?> fetchLatestWeeklyReport() async {
    try {
      final response = await _apiClient.get('/reports/weekly/latest');
      if (response.data == null) return null;
      return WeeklyReport.fromJson(response.data);
    } catch (e, stack) {
      print('Error parsing WeeklyReport: $e\n$stack');
      return null;
    }
  }

  Future<List<WeeklyReport>> fetchWeeklyReportHistory() async {
    try {
      final response = await _apiClient.get('/reports/weekly/history');
      if (response.data == null) return [];
      return (response.data as List).map((r) => WeeklyReport.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> triggerWeeklyReport() async {
    try {
      final response = await _apiClient.post('/reports/weekly/trigger');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

