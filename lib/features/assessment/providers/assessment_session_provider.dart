import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/assessment_service.dart';
import '../models/assessment_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../scoring/providers/scoring_provider.dart';

enum AssessmentSessionStatus { initial, loading, ready, submitting, error }

final assessmentServiceProvider = Provider<AssessmentService>((ref) {
  final api = ref.watch(apiClientProvider);
  return AssessmentService(api);
});

class AssessmentSessionState {
  final Questionnaire? questionnaire;
  final AssessmentSession? activeSession;
  final int currentIndex;
  final Map<String, int> answers;
  final AssessmentSessionStatus status;
  final String? error;

  AssessmentSessionState({
    this.questionnaire,
    this.activeSession,
    this.currentIndex = 0,
    this.answers = const {},
    this.status = AssessmentSessionStatus.initial,
    this.error,
  });

  bool get isLoading => status == AssessmentSessionStatus.loading;
  bool get isSubmitting => status == AssessmentSessionStatus.submitting;

  double get progress {
    if (activeSession == null || activeSession!.shuffledQuestionIds.isEmpty) return 0.0;
    return (currentIndex + 1) / activeSession!.shuffledQuestionIds.length;
  }

  AssessmentSessionState copyWith({
    Questionnaire? questionnaire,
    AssessmentSession? activeSession,
    int? currentIndex,
    Map<String, int>? answers,
    AssessmentSessionStatus? status,
    String? error,
  }) {
    return AssessmentSessionState(
      questionnaire: questionnaire ?? this.questionnaire,
      activeSession: activeSession ?? this.activeSession,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class AssessmentSessionNotifier extends Notifier<AssessmentSessionState> {
  @override
  AssessmentSessionState build() {
    ref.watch(authProvider);
    return AssessmentSessionState();
  }

  Future<void> initializeAssessment(String assessmentId, {String depth = 'standard'}) async {
    state = state.copyWith(status: AssessmentSessionStatus.loading, error: null);
    
    final service = ref.read(assessmentServiceProvider);
    try {
      // 1. Load Questionnaire structure directly
      final questionnaire = await service.getQuestionnaire(assessmentId);
      
      if (questionnaire == null) {
        throw Exception('Questionnaire structure not found on server.');
      }

      if (questionnaire.questions.isEmpty) {
        throw Exception('This assessment has no calibrated questions yet.');
      }
      
      // 2. Start or Resume Session
      AssessmentSession? session = await service.getSession(assessmentId);
      
      if (session == null) {
        session = await service.startSession(assessmentId, depth: depth);
      }

      state = state.copyWith(
        questionnaire: questionnaire,
        activeSession: session,
        currentIndex: session.currentIndex,
        answers: session.answers,
        status: AssessmentSessionStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: AssessmentSessionStatus.error,
        error: 'Communication link interrupted: ${e.toString()}',
      );
    }
  }

  void selectOption(String questionId, int score) {
    if (state.status != AssessmentSessionStatus.ready || state.activeSession == null) return;

    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[questionId] = score;

    final nextIndex = state.currentIndex + 1;
    final isLastQuestion = nextIndex >= state.activeSession!.shuffledQuestionIds.length;

    state = state.copyWith(
      answers: newAnswers,
      currentIndex: isLastQuestion ? state.currentIndex : nextIndex,
    );

    // Auto-save progress to backend
    _autoSave();
  }

  Future<void> _autoSave() async {
    if (state.activeSession == null) return;
    
    final service = ref.read(assessmentServiceProvider);
    try {
      await service.saveProgress(
        state.activeSession!.assessmentId,
        state.answers,
        state.currentIndex,
      );
    } catch (e) {
      // Background save errors are silent but logged
      print('Auto-save failed: $e');
    }
  }

  Future<AssessmentResult?> submit() async {
    if (state.activeSession == null || state.status != AssessmentSessionStatus.ready) return null;
    
    state = state.copyWith(status: AssessmentSessionStatus.submitting);
    final service = ref.read(assessmentServiceProvider);
    try {
      final result = await service.submitAssessment(
        state.activeSession!.assessmentId,
        state.answers,
      );
      
      // Invalidate scoring providers to refresh CMHI score in real-time
      ref.invalidate(latestCMHIProvider);
      ref.invalidate(scoreHistoryProvider);
      ref.invalidate(growthSummaryProvider);
      
      state = state.copyWith(status: AssessmentSessionStatus.ready);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: AssessmentSessionStatus.ready,
        error: 'System encountered a processing error during submission.',
      );
      return null;
    }
  }
}

final assessmentSessionProvider = NotifierProvider<AssessmentSessionNotifier, AssessmentSessionState>(AssessmentSessionNotifier.new);

final activeSessionsProvider = FutureProvider<List<AssessmentSession>>((ref) async {
  ref.watch(authProvider);
  final service = ref.watch(assessmentServiceProvider);
  return service.getAllSessions();
});
