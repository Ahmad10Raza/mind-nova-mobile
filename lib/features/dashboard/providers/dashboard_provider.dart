import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mood/providers/mood_log_provider.dart';
import '../../mood/models/mood_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import '../../habits/providers/habit_provider.dart';
import '../../challenges/providers/challenge_provider.dart';
import '../../scoring/models/scoring_model.dart';

// --- Discovery Hub Visibility State ---
class DiscoveryMinimizedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setMinimized(bool value) => state = value;
}

final discoveryMinimizedProvider = NotifierProvider<DiscoveryMinimizedNotifier, bool>(DiscoveryMinimizedNotifier.new);

// --- Dashboard Mood Trends ---
final moodTrendsProvider = FutureProvider.autoDispose<List<MoodTrend>>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (authState.status == AuthStatus.anonymous || authState.status == AuthStatus.unauthenticated) {
    return [];
  }
  
  final service = ref.watch(moodServiceProvider);
  service.syncPendingMoods().ignore();
  
  return await service.getMoodTrends();
});

enum FocusActionType {
  breathe,
  grounding,
  logMood,
  completeHabit,
  continueChallenge,
  rest,
  takeFirstStep
}

class TodayFocus {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String route;
  final FocusActionType type;
  final double score;

  const TodayFocus({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.route,
    required this.type,
    required this.score,
  });
}

final todayFocusProvider = Provider.autoDispose<AsyncValue<TodayFocus>>((ref) {
  final cmhiAsync = ref.watch(latestCMHIProvider);
  final habitsAsync = ref.watch(todayHabitsProvider);
  final challengeAsync = ref.watch(activeChallengeProvider);

  if (cmhiAsync.isLoading || habitsAsync.isLoading || challengeAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final cmhi = cmhiAsync.value;
  final habits = habitsAsync.value ?? [];
  final challenge = challengeAsync.value;

  final risk = cmhi?.riskCategory ?? RiskCategory.minimal;
  final stressLevel = (cmhi?.dimensions.physiological ?? 0) / 100.0; // Approximation of stress
  
  final unfinishedTasks = challenge != null && !challenge.isCompletedForToday ? 1.0 : 0.0;
  final missedHabits = habits.where((h) => h.logs.isEmpty).length.toDouble();

  final hour = DateTime.now().hour;
  double timeOfDayWeight = 0.0;
  if (hour < 10) timeOfDayWeight = 1.0; // Morning priority
  else if (hour > 20) timeOfDayWeight = 1.5; // Evening wind-down priority

  final scores = <TodayFocus>[];

  // 1. High Risk / Stress Focus
  if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
    scores.add(TodayFocus(
      title: "Let's find some calm together",
      subtitle: "Your stress levels are elevated.",
      ctaLabel: "Start Breathing",
      route: "/breathing",
      type: FocusActionType.breathe,
      score: (stressLevel * 4.0) + 10.0, // Force priority
    ));
  } else {
    // 2. Challenge Focus
    if (unfinishedTasks > 0) {
      scores.add(TodayFocus(
        title: "Continue your journey",
        subtitle: "You have a pending challenge step.",
        ctaLabel: "Resume Challenge",
        route: "/challenges/active", // Adjust if needed
        type: FocusActionType.continueChallenge,
        score: (stressLevel * 2) + (unfinishedTasks * 3.5) + timeOfDayWeight,
      ));
    }

    // 3. Habit Focus
    if (missedHabits > 0) {
      scores.add(TodayFocus(
        title: "Maintain your streak",
        subtitle: "You have ${missedHabits.toInt()} unfinished habit(s) today.",
        ctaLabel: "View Habits",
        route: "/habits", // Route to the actual habits screen
        type: FocusActionType.completeHabit,
        score: (stressLevel * 2) + (missedHabits * 2.5) + timeOfDayWeight,
      ));
    }

    // 4. Time-based generic focus
    if (hour >= 20 || hour < 6) {
      scores.add(TodayFocus(
        title: "Prepare for rest",
        subtitle: "Wind down before sleep.",
        ctaLabel: "Night Mode",
        route: "/breathing",
        type: FocusActionType.rest,
        score: timeOfDayWeight * 3.0,
      ));
    } else if (cmhi == null) {
      // 5. Empty State
      scores.add(const TodayFocus(
        title: "Start your journey",
        subtitle: "Take your first step today.",
        ctaLabel: "Log Mood",
        route: "/mood-checkin",
        type: FocusActionType.takeFirstStep,
        score: 5.0,
      ));
    } else {
      scores.add(const TodayFocus(
        title: "Take a mindful pause",
        subtitle: "Check in with yourself.",
        ctaLabel: "Log Mood",
        route: "/mood-checkin",
        type: FocusActionType.logMood,
        score: 2.0,
      ));
    }
  }

  if (scores.isEmpty) {
    return AsyncValue.data(const TodayFocus(
      title: "Take a mindful pause",
      subtitle: "Check in with yourself.",
      ctaLabel: "Log Mood",
      route: "/mood-checkin",
      type: FocusActionType.logMood,
      score: 1.0,
    ));
  }

  scores.sort((a, b) => b.score.compareTo(a.score));
  return AsyncValue.data(scores.first);
});
