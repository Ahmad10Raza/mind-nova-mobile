import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mood_service.dart';
import '../models/mood_model.dart';
import '../models/ai_suggestion_model.dart';
import '../models/mood_question_model.dart';
import '../providers/mood_log_provider.dart';
import 'analytics_provider.dart';
import '../../../core/services/local_notification_service.dart';

enum MoodFlowState {
  selection,
  intensity,
  tags,
  loadingQuestions,
  followUp,
  loadingSuggestions,
  aiSuggestions,
  positiveMemory,
  crisis,
  completed
}

class MoodFlowData {
  final MoodFlowState state;
  final String? selectedMood;
  final String? category;
  final String? intensity;
  final List<String> tags;
  final List<Map<String, String>> answers;
  final int currentQuestionIndex;

  // API response data
  final Map<String, dynamic>? contextConfig;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic>? resultData;
  final String? logId;
  final String? error;
  final bool isNavigating; // New flag to prevent duplicate navigation triggers

  const MoodFlowData({
    this.state = MoodFlowState.selection,
    this.selectedMood,
    this.category,
    this.intensity,
    this.tags = const [],
    this.answers = const [],
    this.currentQuestionIndex = 0,
    this.contextConfig,
    this.questions = const [],
    this.resultData,
    this.logId,
    this.error,
    this.isNavigating = false,
  });

  MoodFlowData copyWith({
    MoodFlowState? state,
    String? selectedMood,
    String? category,
    String? intensity,
    List<String>? tags,
    List<Map<String, String>>? answers,
    int? currentQuestionIndex,
    Map<String, dynamic>? contextConfig,
    List<Map<String, dynamic>>? questions,
    Map<String, dynamic>? resultData,
    String? logId,
    String? error,
    bool? isNavigating,
  }) {
    return MoodFlowData(
      state: state ?? this.state,
      selectedMood: selectedMood ?? this.selectedMood,
      category: category ?? this.category,
      intensity: intensity ?? this.intensity,
      tags: tags ?? this.tags,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      contextConfig: contextConfig ?? this.contextConfig,
      questions: questions ?? this.questions,
      resultData: resultData ?? this.resultData,
      logId: logId ?? this.logId,
      error: error ?? this.error,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}

class MoodFlowNotifier extends Notifier<MoodFlowData> {
  @override
  MoodFlowData build() => const MoodFlowData();

  void selectMood(String mood, String moodCategory) {
    state = state.copyWith(
      selectedMood: mood,
      category: moodCategory,
      state: MoodFlowState.intensity,
    );
  }

  void selectIntensity(String selectedIntensity) {
    state = state.copyWith(
      intensity: selectedIntensity,
      state: MoodFlowState.tags,
    );
  }

  void toggleTag(String tag) {
    final newTags = List<String>.from(state.tags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    state = state.copyWith(tags: newTags);
  }

  /// After tags are picked, fetch dynamic questions from the backend
  Future<void> submitTagsAndFetchQuestions() async {
    state = state.copyWith(state: MoodFlowState.loadingQuestions);
    try {
      final service = ref.read(moodServiceProvider);
      final rules = await service.getContextRules(
        mood: state.selectedMood ?? 'Neutral',
        intensity: state.intensity ?? 'moderate',
        tags: state.tags,
      );

      final config = rules['configuration'] as Map<String, dynamic>?;
      final rawQuestions = (rules['questions'] as List?)
          ?.map((q) => Map<String, dynamic>.from(q))
          .toList() ?? [];

      state = state.copyWith(
        state: MoodFlowState.followUp,
        contextConfig: config,
        questions: rawQuestions,
        currentQuestionIndex: 0,
        answers: [],
      );
    } catch (e) {
      // Fallback: skip to suggestions if questions fail
      state = state.copyWith(
        state: MoodFlowState.followUp,
        questions: [
          {'id': 'fallback_q1', 'text': 'How are you feeling right now?'},
          {'id': 'fallback_q2', 'text': 'Is there anything on your mind?'},
        ],
        currentQuestionIndex: 0,
        answers: [],
        error: e.toString(),
      );
    }
  }

  /// Submit an answer to the current question, advance or finalize
  void submitAnswer(String questionId, String answer) {
    final newAnswers = List<Map<String, String>>.from(state.answers);
    newAnswers.add({'questionId': questionId, 'answer': answer});

    final isLast = state.currentQuestionIndex >= state.questions.length - 1;

    if (isLast) {
      state = state.copyWith(
        answers: newAnswers,
        state: MoodFlowState.loadingSuggestions,
      );
      _submitToBackend(newAnswers);
    } else {
      state = state.copyWith(
        answers: newAnswers,
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// Skip remaining questions and go straight to submission
  void skipToSuggestions() {
    state = state.copyWith(state: MoodFlowState.loadingSuggestions);
    _submitToBackend(state.answers);
  }

  Future<void> _submitToBackend(List<Map<String, String>> answers) async {
    try {
      final service = ref.read(moodServiceProvider);
      final result = await service.logIntelligent(
        mood: state.selectedMood ?? 'Neutral',
        intensity: state.intensity ?? 'moderate',
        tags: state.tags,
        answers: answers,
      );

      // Invalidate caches to ensure fresh data on dashboard/history
      ref.invalidate(novaSuggestsProvider);
      ref.invalidate(moodHomeWidgetProvider);
      ref.invalidate(moodHistoryProvider);

      final status = result['status'] as String?;

      if (status == 'CRITICAL_INTERVENTION') {
        state = state.copyWith(
          state: MoodFlowState.crisis,
          resultData: result,
          logId: result['logId'],
        );
      } else {
        // Nudge Logic: Trigger if stress is high
        final stress = result['stress'] as num?;
        if (stress != null && stress > 7) {
          LocalNotificationService.showStressNudge();
        }

        // Check if positive mood → show memory card opportunity
        final isMoodPositive = state.category == 'positive';
        state = state.copyWith(
          state: isMoodPositive ? MoodFlowState.positiveMemory : MoodFlowState.aiSuggestions,
          resultData: result,
          logId: result['logId'],
        );
      }
    } catch (e) {
      // Fallback: show suggestions with fallback data so screen is never empty
      state = state.copyWith(
        state: MoodFlowState.aiSuggestions,
        resultData: {
          'status': 'FALLBACK',
          'suggestions': [
            {'type': 'IMMEDIATE_ACTION', 'title': 'Take a Breath', 'desc': 'Hold for 4 seconds.'},
            {'type': 'TOOL_RECOMMENDATION', 'title': 'Journal', 'desc': 'Write about how you feel.'},
            {'type': 'REFLECTION_PROMPT', 'title': 'Reflect', 'desc': 'What do you need right now?'},
          ],
          'quickTools': ['Journal', 'Breathing', 'AI Chat'],
        },
        error: e.toString(),
      );
    }
  }

  void goBack() {
    switch (state.state) {
      case MoodFlowState.intensity:
        // Handled by screen pop
        break;
      case MoodFlowState.tags:
        state = state.copyWith(state: MoodFlowState.intensity);
        break;
      case MoodFlowState.followUp:
        if (state.currentQuestionIndex > 0) {
          // Remove last answer if we are moving back
          final newAnswers = List<Map<String, String>>.from(state.answers);
          if (newAnswers.isNotEmpty) newAnswers.removeLast();
          state = state.copyWith(
            currentQuestionIndex: state.currentQuestionIndex - 1,
            answers: newAnswers,
          );
        } else {
          state = state.copyWith(state: MoodFlowState.tags);
        }
        break;
      default:
        break;
    }
  }

  void reset() {
    state = const MoodFlowData();
  }

  void setNavigating(bool value) {
    state = state.copyWith(isNavigating: value);
  }
}

final moodFlowProvider = NotifierProvider<MoodFlowNotifier, MoodFlowData>(
  () => MoodFlowNotifier(),
);
