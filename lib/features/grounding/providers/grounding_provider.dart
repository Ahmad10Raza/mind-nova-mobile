import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grounding_model.dart';
import '../data/grounding_service.dart';
import '../../../core/network/api_client.dart';

// ─── Service Provider ───────────────────────────────────────────────
final groundingServiceProvider = Provider<GroundingService>((ref) {
  return GroundingService(ref.watch(apiClientProvider));
});

// ─── Dashboard ──────────────────────────────────────────────────────
final groundingDashboardProvider = FutureProvider<GroundingDashboard>((ref) {
  return ref.watch(groundingServiceProvider).getDashboard();
});

// ─── Analytics ──────────────────────────────────────────────────────
final groundingAnalyticsProvider = FutureProvider<GroundingAnalyticsModel>((ref) {
  return ref.watch(groundingServiceProvider).getAnalytics();
});

// ─── History ────────────────────────────────────────────────────────
class GroundingHistoryState {
  final List<GroundingSession> sessions;
  final bool isLoading;
  final bool hasReachedMax;

  GroundingHistoryState({
    this.sessions = const [],
    this.isLoading = true,
    this.hasReachedMax = false,
  });

  GroundingHistoryState copyWith({
    List<GroundingSession>? sessions,
    bool? isLoading,
    bool? hasReachedMax,
  }) {
    return GroundingHistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class GroundingHistoryNotifier extends Notifier<GroundingHistoryState> {
  int _skip = 0;
  final int _take = 20;

  @override
  GroundingHistoryState build() {
    Future.microtask(fetchInitial);
    return GroundingHistoryState();
  }

  GroundingService get _service => ref.read(groundingServiceProvider);

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.getHistory(skip: 0, take: _take);
      _skip = data.length;
      state = state.copyWith(
        sessions: data,
        isLoading: false,
        hasReachedMax: data.length < _take,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoading || state.hasReachedMax) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await _service.getHistory(skip: _skip, take: _take);
      _skip += data.length;
      state = state.copyWith(
        sessions: [...state.sessions, ...data],
        isLoading: false,
        hasReachedMax: data.length < _take,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void prependSession(GroundingSession session) {
    state = state.copyWith(sessions: [session, ...state.sessions]);
  }
}

final groundingHistoryProvider =
    NotifierProvider<GroundingHistoryNotifier, GroundingHistoryState>(GroundingHistoryNotifier.new);

// ─── Active Session Tracker ─────────────────────────────────────────
// Tracks the currently running exercise (type + start time) so we can
// compute duration when the user completes or exits.
class ActiveGroundingSession {
  final GroundingExerciseType exerciseType;
  final SafePlaceEnvironment? environment;
  final DateTime startTime;

  ActiveGroundingSession({
    required this.exerciseType,
    this.environment,
    required this.startTime,
  });

  int get elapsedSeconds => DateTime.now().difference(startTime).inSeconds;
}

class ActiveGroundingNotifier extends Notifier<ActiveGroundingSession?> {
  @override
  ActiveGroundingSession? build() => null;

  void start(GroundingExerciseType type, {SafePlaceEnvironment? environment}) {
    state = ActiveGroundingSession(
      exerciseType: type,
      environment: environment,
      startTime: DateTime.now(),
    );
  }

  Future<GroundingSession?> complete({
    int? calmBefore,
    int? calmAfter,
    bool? wouldRepeat,
    bool completedFull = true,
  }) async {
    final active = state;
    if (active == null) return null;
    state = null; // Clear immediately for optimistic UX

    try {
      final session = await ref.read(groundingServiceProvider).logSession(
        exerciseType: active.exerciseType,
        environment: active.environment,
        durationSecs: active.elapsedSeconds,
        calmBefore: calmBefore,
        calmAfter: calmAfter,
        wouldRepeat: wouldRepeat,
        completedFull: completedFull,
      );

      // Prepend to history and refresh dashboard/analytics
      ref.read(groundingHistoryProvider.notifier).prependSession(session);
      ref.invalidate(groundingDashboardProvider);
      ref.invalidate(groundingAnalyticsProvider);

      return session;
    } catch (_) {
      return null;
    }
  }

  void abandon() {
    state = null;
  }
}

final activeGroundingSessionProvider =
    NotifierProvider<ActiveGroundingNotifier, ActiveGroundingSession?>(ActiveGroundingNotifier.new);
