import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/meditation_model.dart';
import '../../../core/network/api_client.dart';

class MeditationService {
  final ApiClient _apiClient;
  static const _offlineHistoryKey = 'meditation_offline_history';

  MeditationService(this._apiClient);

  Future<MeditationDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/meditation/dashboard');
      return MeditationDashboardStats.fromJson(response.data);
    } catch (_) {
      final offline = await _getOfflineSessions();
      if (offline.isEmpty) throw Exception('Offline');
      
      int totalSecs = 0;
      int totalLift = 0;
      int liftCount = 0;
      Map<String, int> catCount = {};
      Map<String, int> catLift = {};
      Map<String, int> catLiftCount = {};

      for (var s in offline) {
        totalSecs += s.durationSecs;
        final cat = s.content?.category ?? 'RECOVERY';
        catCount[cat] = (catCount[cat] ?? 0) + 1;
        
        if (s.calmBefore != null && s.calmAfter != null) {
          final lift = s.calmAfter! - s.calmBefore!;
          totalLift += lift;
          liftCount++;
          
          catLift[cat] = (catLift[cat] ?? 0) + lift;
          catLiftCount[cat] = (catLiftCount[cat] ?? 0) + 1;
        }
      }

      double avgImprovement = liftCount > 0 ? (totalLift / liftCount) * 10 : 0.0;
      
      String? favoriteCategory;
      int maxFreq = 0;
      catCount.forEach((cat, freq) {
        if (freq > maxFreq) {
          maxFreq = freq;
          favoriteCategory = cat;
        }
      });

      String? mostEffectiveCategory;
      double maxAvgLift = -1;
      catLift.forEach((cat, total) {
        final avg = total / catLiftCount[cat]!;
        if (avg > maxAvgLift) {
          maxAvgLift = avg;
          mostEffectiveCategory = cat;
        }
      });

      return MeditationDashboardStats(
        currentStreak: 1,
        totalSessions: offline.length,
        totalMinutes: totalSecs ~/ 60,
        averageCalmImprovement: avgImprovement,
        favoriteCategory: favoriteCategory,
        mostEffectiveCategory: mostEffectiveCategory,
        recentSessions: offline.take(3).toList(),
      );
    }
  }

  Future<List<MeditationContent>> getMasterCatalog({String? category}) async {
    try {
      final response = await _apiClient.get(
        '/meditation/catalog',
        queryParameters: category != null ? {'category': category} : null,
      );
      return (response.data as List).map((json) => MeditationContent.fromJson(json)).toList();
    } catch (_) {
      final mocks = [
        MeditationContent(
          id: 'mock_1',
          title: 'Deep Sleep Binaurals',
          subtitle: 'Drift away with 432Hz binaural beats.',
          description: 'A deeply restorative sleep track designed to slow down brain waves and prepare you for deep REM sleep.',
          category: 'SLEEP',
          durationMinutes: 45,
          difficulty: 'Beginner',
          audioUrl: 'audio/sleep.mp3',
        ),
        MeditationContent(
          id: 'mock_2',
          title: 'Panic Reset Protocol',
          subtitle: 'A fast-acting tool to lower your heart rate.',
          description: 'Guided breathwork to help you ground yourself when experiencing extreme anxiety.',
          category: 'ANXIETY_RELIEF',
          durationMinutes: 5,
          difficulty: 'Beginner',
          audioUrl: 'audio/space_ambience.mp3',
        ),
        MeditationContent(
          id: 'mock_3',
          title: 'Morning Momentum',
          subtitle: 'Start your day with intent and clarity.',
          description: 'Set your focus for the day with positive visualization.',
          category: 'MORNING',
          durationMinutes: 10,
          difficulty: 'Intermediate',
          audioUrl: 'audio/space_ambience.mp3',
        )
      ];
      if (category == null) return mocks;
      return mocks.where((m) => m.category == category).toList();
    }
  }

  Future<List<MeditationContent>> getRecommended() async {
    try {
      final response = await _apiClient.get('/meditation/recommended');
      return (response.data as List).map((json) => MeditationContent.fromJson(json)).toList();
    } catch (_) {
      // Return mock data for offline support
      return [
        MeditationContent(
          id: 'mock_2',
          title: 'Panic Reset Protocol',
          subtitle: 'A fast-acting tool to lower your heart rate.',
          description: 'Guided breathwork to help you ground yourself when experiencing extreme anxiety.',
          category: 'ANXIETY_RELIEF',
          durationMinutes: 5,
          difficulty: 'Beginner',
          audioUrl: 'audio/space_ambience.mp3',
        )
      ];
    }
  }

  Future<List<String>> getCategories() async {
    final response = await _apiClient.get('/meditation/categories');
    return List<String>.from(response.data);
  }

  Future<List<MeditationSession>> getRecentSessions({int limit = 20}) async {
    List<MeditationSession> online = [];
    try {
      final response = await _apiClient.get('/meditation/history', queryParameters: {'take': limit.toString()});
      online = (response.data as List).map((json) => MeditationSession.fromJson(json)).toList();
    } catch (_) {
      // Ignore API error and just use offline
    }
    
    final offline = await _getOfflineSessions();
    // Combine and sort by date descending
    final combined = [...online, ...offline];
    combined.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    return combined.take(limit).toList();
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
      // Save offline if API fails
      final newSession = MeditationSession(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'offline_user',
        contentId: contentId,
        durationSecs: durationSecs,
        calmBefore: calmBefore,
        calmAfter: calmAfter,
        completedFull: true,
        completedAt: DateTime.now(),
        content: MeditationContent(
          id: contentId,
          title: 'Offline Session',
          category: 'RECOVERY',
          durationMinutes: durationSecs ~/ 60,
          difficulty: 'N/A',
          audioUrl: '',
        ),
      );
      await _saveOfflineSession(newSession);
    }
  }

  // --- Offline Storage Helpers ---
  Future<List<MeditationSession>> _getOfflineSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_offlineHistoryKey) ?? [];
    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr);
      return MeditationSession.fromJson(map);
    }).toList();
  }

  Future<void> _saveOfflineSession(MeditationSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_offlineHistoryKey) ?? [];
    
    final map = {
      'id': session.id,
      'userId': session.userId,
      'contentId': session.contentId,
      'durationSecs': session.durationSecs,
      'calmBefore': session.calmBefore,
      'calmAfter': session.calmAfter,
      'completedFull': session.completedFull,
      'completedAt': session.completedAt.toIso8601String(),
      'content': {
        'id': session.content?.id ?? session.contentId,
        'title': session.content?.title ?? 'Recent Session',
        'category': session.content?.category ?? 'RECOVERY',
        'durationMinutes': session.content?.durationMinutes ?? 0,
        'difficulty': session.content?.difficulty ?? 'General',
        'audioUrl': session.content?.audioUrl ?? '',
      }
    };
    
    jsonList.add(jsonEncode(map));
    await prefs.setStringList(_offlineHistoryKey, jsonList);
  }
}
