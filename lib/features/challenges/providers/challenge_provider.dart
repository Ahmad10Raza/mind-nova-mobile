import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/challenge_service.dart';
import '../models/challenge_model.dart';

// ─── Service Provider ────────────────────────────────────────────
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return ChallengeService(ref.read(apiClientProvider));
});

// ─── List All Challenges ─────────────────────────────────────────
final challengeListProvider = FutureProvider<List<Challenge>>((ref) async {
  final service = ref.read(challengeServiceProvider);
  return service.getChallenges();
});

// ─── Challenge Detail ────────────────────────────────────────────
final challengeDetailProvider =
    FutureProvider.family<Challenge, String>((ref, id) async {
  final service = ref.read(challengeServiceProvider);
  return service.getChallengeDetail(id);
});

// ─── Active Challenge ────────────────────────────────────────────
final activeChallengeProvider = FutureProvider<UserChallenge?>((ref) async {
  final service = ref.read(challengeServiceProvider);
  return service.getActiveChallenge();
});

// ─── Challenge Actions ───────────────────────────────────────────

class ChallengeActionState {
  final bool isLoading;
  final String? error;
  final UserChallenge? result;

  ChallengeActionState({this.isLoading = false, this.error, this.result});

  ChallengeActionState copyWith({
    bool? isLoading,
    String? error,
    UserChallenge? result,
  }) {
    return ChallengeActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class ChallengeActionNotifier extends Notifier<ChallengeActionState> {
  @override
  ChallengeActionState build() {
    return ChallengeActionState();
  }

  Future<UserChallenge?> startChallenge({
    required String challengeId,
    String? preferredTime,
    bool reminderEnabled = true,
    String? reminderTime,
  }) async {
    final service = ref.read(challengeServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await service.startChallenge(
        challengeId: challengeId,
        preferredTime: preferredTime,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
      );
      state = ChallengeActionState(isLoading: false, result: result);
      ref.invalidate(activeChallengeProvider);
      ref.invalidate(challengeListProvider);
      return result;
    } catch (e) {
      state = ChallengeActionState(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<UserChallenge?> completeDay({
    required String userChallengeId,
    required int dayNumber,
    required int tasksCompleted,
    required int totalTasks,
  }) async {
    final service = ref.read(challengeServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await service.completeDay(
        userChallengeId: userChallengeId,
        dayNumber: dayNumber,
        tasksCompleted: tasksCompleted,
        totalTasks: totalTasks,
      );
      state = ChallengeActionState(isLoading: false, result: result);
      ref.invalidate(activeChallengeProvider);
      return result;
    } catch (e) {
      state = ChallengeActionState(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> abandonChallenge({
    required String userChallengeId,
    bool pause = false,
    String? reason,
  }) async {
    final service = ref.read(challengeServiceProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      await service.abandonChallenge(
        userChallengeId: userChallengeId,
        pause: pause,
        reason: reason,
      );
      state = ChallengeActionState(isLoading: false);
      ref.invalidate(activeChallengeProvider);
      ref.invalidate(challengeListProvider);
    } catch (e) {
      state = ChallengeActionState(isLoading: false, error: e.toString());
    }
  }
}

final challengeActionProvider =
    NotifierProvider<ChallengeActionNotifier, ChallengeActionState>(() {
  return ChallengeActionNotifier();
});
