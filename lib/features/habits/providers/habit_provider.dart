import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/habit_service.dart';
import '../models/habit_model.dart';
import '../../../core/network/api_client.dart';

final habitServiceProvider = Provider<HabitService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HabitService(apiClient);
});

final todayHabitsProvider = FutureProvider.autoDispose<List<Habit>>((ref) async {
  final service = ref.watch(habitServiceProvider);
  return service.getTodayHabits();
});

class HabitCreateState {
  final bool isSubmitting;
  final String? error;

  HabitCreateState({this.isSubmitting = false, this.error});

  HabitCreateState copyWith({bool? isSubmitting, String? error}) {
    return HabitCreateState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

class HabitCreateNotifier extends Notifier<HabitCreateState> {
  @override
  HabitCreateState build() {
    return HabitCreateState();
  }

  Future<bool> createHabit({
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
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final service = ref.read(habitServiceProvider);
      await service.createHabit(
        title: title,
        description: description,
        category: category,
        duration: duration,
        isMicro: isMicro,
        isRoutine: isRoutine,
        routineType: routineType,
        preferredTime: preferredTime,
        triggerType: triggerType,
        environment: environment,
        difficultyLevel: difficultyLevel,
      );
      ref.invalidate(todayHabitsProvider);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final habitCreateProvider = NotifierProvider<HabitCreateNotifier, HabitCreateState>(() {
  return HabitCreateNotifier();
});

class HabitCompletionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> completeHabit({
    required String habitId,
    int? moodBefore,
    int? moodAfter,
    String? note,
    int? actualDuration,
    DateTime? forDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(habitServiceProvider);
      await service.completeHabit(
        habitId: habitId,
        moodBefore: moodBefore,
        moodAfter: moodAfter,
        note: note,
        actualDuration: actualDuration,
        forDate: forDate,
      );
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(habitHistoryProvider);
      ref.invalidate(habitAnalyticsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final habitCompletionProvider = NotifierProvider<HabitCompletionNotifier, AsyncValue<void>>(() {
  return HabitCompletionNotifier();
});
final habitTrendProvider = Provider.autoDispose.family<double, String>((ref, habitId) {
  final habitsAsync = ref.watch(todayHabitsProvider);
  return habitsAsync.maybeWhen(
    data: (habits) {
      final habit = habits.firstWhere((h) => h.id == habitId);
      if (habit.logs.isEmpty) return 0.0;
      
      // Calculate completion rate over the last 7 days
      final now = DateTime.now();
      final last7Days = now.subtract(const Duration(days: 7));
      final logsInLast7Days = habit.logs.where((l) => l.completedAt.isAfter(last7Days)).length;
      
      return logsInLast7Days / 7.0;
    },
    orElse: () => 0.0,
  );
});

final habitMidnightRefreshProvider = StreamProvider<bool>((ref) async* {
  while (true) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);
    
    await Future.delayed(timeUntilMidnight);
    yield true;
  }
});

final habitHistoryProvider = FutureProvider.autoDispose.family<List<Habit>, int>((ref, days) async {
  final service = ref.watch(habitServiceProvider);
  return service.getHistory(days: days);
});

final habitAnalyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(habitServiceProvider);
  return service.getAnalytics();
});
