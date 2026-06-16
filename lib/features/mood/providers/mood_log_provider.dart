import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mood_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/database/local_db_service.dart';
import '../../safety/providers/safety_provider.dart';
import '../../safety/models/crisis_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'analytics_provider.dart';

final moodServiceProvider = Provider<MoodService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MoodService(apiClient);
});

class MoodFormState {
  final int? score;
  final String? label;
  final Map<String, dynamic> contextData;
  final bool isSubmitting;
  final String? error;
  final AppCrisisAnalysis? lastAnalysis;

  MoodFormState({
    this.score,
    this.label,
    this.contextData = const {},
    this.isSubmitting = false,
    this.error,
    this.lastAnalysis,
  });

  MoodFormState copyWith({
    int? score,
    String? label,
    Map<String, dynamic>? contextData,
    bool? isSubmitting,
    String? error,
    AppCrisisAnalysis? lastAnalysis,
  }) {
    return MoodFormState(
      score: score ?? this.score,
      label: label ?? this.label,
      contextData: contextData ?? this.contextData,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      lastAnalysis: lastAnalysis ?? this.lastAnalysis,
    );
  }
}

class MoodFormNotifier extends Notifier<MoodFormState> {
  @override
  MoodFormState build() {
    return MoodFormState();
  }

  void setInitialMood(String label) {
    int score = 3;
    switch (label) {
      case 'Overjoyed': score = 5; break;
      case 'Happy': score = 4; break;
      case 'Neutral': score = 3; break;
      case 'Sad': score = 2; break;
      case 'Depressed': score = 1; break;
    }
    state = state.copyWith(score: score, label: label, error: null, lastAnalysis: null);
  }

  void setContextData(String reason, String sleepData, String foodData) {
    final newData = Map<String, dynamic>.from(state.contextData);
    newData['reason'] = reason;
    newData['sleepData'] = sleepData;
    newData['foodData'] = foodData;
    state = state.copyWith(contextData: newData);
  }

  Future<bool> submit() async {
    if (state.score == null) return false;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final service = ref.read(moodServiceProvider);
      // Format context data string
      String compiledNote = '';
      if (state.contextData.isNotEmpty) {
        compiledNote = 'Reason: ${state.contextData['reason'] ?? ''} | Sleep: ${state.contextData['sleepData'] ?? ''} | Food: ${state.contextData['foodData'] ?? ''}';
      }

      // Bridge old state data to the new MoodLog API shape
      final mappedIntensity = state.score! > 3 ? 'strong' : state.score! == 3 ? 'moderate' : 'extreme';
      final mappedCategory = state.score! > 3 ? 'positive' : state.score! == 3 ? 'neutral' : 'negative';

      final result = await service.logMood(
        moodName: state.label ?? 'Unknown',
        category: mappedCategory,
        intensity: mappedIntensity,
        tags: [state.label ?? 'Unknown'],
        notes: compiledNote.isNotEmpty ? compiledNote : null,
      );

      AppCrisisAnalysis? analysis;
      // 4. Handle Crisis Analysis if present (using safety flag from new schema)
      if (result.aiSafetyFlag == true) {
        analysis = AppCrisisAnalysis(riskLevel: CrisisRiskLevel.high, triggerScreen: true, category: CrisisCategory.other, suggestions: []);
        ref.read(safetyProvider.notifier).triggerCrisis(analysis!);
      }

      // Preserve lastAnalysis while resetting other fields
      state = MoodFormState(lastAnalysis: analysis);

      // Invalidate caches to ensure fresh data on dashboard/history
      ref.invalidate(novaSuggestsProvider);
      ref.invalidate(moodHomeWidgetProvider);
      ref.invalidate(moodHistoryProvider);

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final moodFormProvider = NotifierProvider<MoodFormNotifier, MoodFormState>(() {
  return MoodFormNotifier();
});

final moodStreakProvider = FutureProvider.autoDispose<int>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.status == AuthStatus.unauthenticated) {
    return 0;
  }
  
  final service = ref.watch(moodServiceProvider);
  try {
    final data = await service.getMoodStreak();
    return data['currentStreak'] as int? ?? 0;
  } catch (e) {
    return 0;
  }
});
