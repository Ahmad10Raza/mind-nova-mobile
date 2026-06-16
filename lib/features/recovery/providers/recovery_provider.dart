import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_nova_mobile/core/network/api_client.dart';
import 'package:audio_service/audio_service.dart';
import '../data/recovery_audio_handler.dart';
import '../data/recovery_service.dart';
import '../models/recovery_model.dart';

final recoveryAudioHandlerProvider = Provider<RecoveryAudioHandler>((ref) => recoveryAudioHandler);

final recoveryServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecoveryService(apiClient);
});

final recoverySessionsProvider = FutureProvider.family<List<RecoverySession>, String?>((ref, category) async {
  final service = ref.watch(recoveryServiceProvider);
  return service.getSessions(category: category);
});

final recoveryScoreProvider = FutureProvider<RecoveryScore>((ref) async {
  final service = ref.watch(recoveryServiceProvider);
  return service.getScore();
});

class SelectedRecoveryNeedNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setNeed(String? need) {
    state = need;
  }
}

final selectedRecoveryNeedProvider = NotifierProvider<SelectedRecoveryNeedNotifier, String?>(() => SelectedRecoveryNeedNotifier());

final recoveryRecommendationProvider = FutureProvider<RecoveryRecommendation>((ref) async {
  final service = ref.watch(recoveryServiceProvider);
  final need = ref.watch(selectedRecoveryNeedProvider);
  return service.getRecommendation(category: need);
});

final recoveryHistoryProvider = FutureProvider<List<RecoveryLog>>((ref) async {
  final service = ref.watch(recoveryServiceProvider);
  return service.getHistory();
});

// State for active session
class ActiveRecoverySessionState {
  final RecoveryLog? log;
  final bool isTimerRunning;
  final int elapsedSeconds;
  final int currentStageIndex;
  final int stageElapsedSeconds;

  ActiveRecoverySessionState({
    this.log,
    this.isTimerRunning = false,
    this.elapsedSeconds = 0,
    this.currentStageIndex = 0,
    this.stageElapsedSeconds = 0,
  });

  ActiveRecoverySessionState copyWith({
    RecoveryLog? log,
    bool? isTimerRunning,
    int? elapsedSeconds,
    int? currentStageIndex,
    int? stageElapsedSeconds,
  }) {
    return ActiveRecoverySessionState(
      log: log ?? this.log,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      stageElapsedSeconds: stageElapsedSeconds ?? this.stageElapsedSeconds,
    );
  }
}

class ActiveRecoverySessionNotifier extends Notifier<ActiveRecoverySessionState> {
  @override
  ActiveRecoverySessionState build() => ActiveRecoverySessionState();

  Future<void> start(String sessionId) async {
    final service = ref.read(recoveryServiceProvider);
    final log = await service.startSession(sessionId);
    state = state.copyWith(
      log: log, 
      isTimerRunning: true, 
      elapsedSeconds: 0,
      currentStageIndex: 0,
      stageElapsedSeconds: 0,
    );
  }

  void tick() {
    if (state.isTimerRunning) {
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
        stageElapsedSeconds: state.stageElapsedSeconds + 1,
      );

      // Auto-transition logic
      final session = state.log?.session;
      if (session != null && state.currentStageIndex < session.stages.length) {
        final currentStage = session.stages[state.currentStageIndex];
        if (state.stageElapsedSeconds >= currentStage.duration) {
          nextStage();
        }
      }
    }
  }

  void nextStage() {
    final session = state.log?.session;
    if (session == null) return;
    
    if (state.currentStageIndex < session.stages.length - 1) {
      state = state.copyWith(
        currentStageIndex: state.currentStageIndex + 1,
        stageElapsedSeconds: 0,
      );
    }
  }

  void previousStage() {
    if (state.currentStageIndex > 0) {
      state = state.copyWith(
        currentStageIndex: state.currentStageIndex - 1,
        stageElapsedSeconds: 0,
      );
    }
  }

  Future<RecoveryLog> complete({int? mood, int? stress}) async {
    if (state.log == null) throw Exception('No active session');
    
    final service = ref.read(recoveryServiceProvider);
    final completedLog = await service.completeSession(
      state.log!.id,
      mood: mood,
      stress: stress,
      duration: state.elapsedSeconds,
    );
    
    state = ActiveRecoverySessionState(); // Reset
    return completedLog;
  }

  void toggleTimer() {
    state = state.copyWith(isTimerRunning: !state.isTimerRunning);
  }

  void stop() {
    state = ActiveRecoverySessionState();
  }
}

final activeRecoverySessionProvider = NotifierProvider<ActiveRecoverySessionNotifier, ActiveRecoverySessionState>(ActiveRecoverySessionNotifier.new);
