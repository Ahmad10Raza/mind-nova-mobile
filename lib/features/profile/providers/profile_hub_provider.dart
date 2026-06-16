import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import '../../habits/providers/habit_provider.dart';
import '../../mood/providers/analytics_provider.dart';
import '../../challenges/providers/challenge_provider.dart';
import '../../focus/providers/focus_provider.dart';
import '../../grounding/providers/grounding_provider.dart';
import '../../therapist/providers/therapist_provider.dart';
import '../../groups/providers/group_provider.dart';

import '../../scoring/models/scoring_model.dart';

class ProfileHubState {
  final String identityLine;
  final double growthScore; // 0 to 100
  final double growthDelta; // +/- compared to last week (mocked for now)
  final CMHIScore? latestCMHI;
  final double habitConsistency; // 0.0 to 1.0
  final double recoveryScore; // 0.0 to 100.0
  final String moodTrend; // 'Improving', 'Stable', 'Declining'
  final String? weeklyInsightSummary;
  final int moodLogsCount;
  final int focusMinutes;
  final int groundingSessionsCount;
  final int activeGroupsCount;
  final DateTime? nextSessionDate;
  final bool isLoading;

  const ProfileHubState({
    required this.identityLine,
    required this.growthScore,
    required this.growthDelta,
    this.latestCMHI,
    required this.habitConsistency,
    required this.recoveryScore,
    required this.moodTrend,
    this.weeklyInsightSummary,
    this.moodLogsCount = 0,
    this.focusMinutes = 0,
    this.groundingSessionsCount = 0,
    this.activeGroupsCount = 0,
    this.nextSessionDate,
    this.isLoading = false,
  });

  ProfileHubState copyWith({
    String? identityLine,
    double? growthScore,
    double? growthDelta,
    CMHIScore? latestCMHI,
    double? habitConsistency,
    double? recoveryScore,
    String? moodTrend,
    String? weeklyInsightSummary,
    int? moodLogsCount,
    int? focusMinutes,
    int? groundingSessionsCount,
    int? activeGroupsCount,
    DateTime? nextSessionDate,
    bool? isLoading,
  }) {
    return ProfileHubState(
      identityLine: identityLine ?? this.identityLine,
      growthScore: growthScore ?? this.growthScore,
      growthDelta: growthDelta ?? this.growthDelta,
      latestCMHI: latestCMHI ?? this.latestCMHI,
      habitConsistency: habitConsistency ?? this.habitConsistency,
      recoveryScore: recoveryScore ?? this.recoveryScore,
      moodTrend: moodTrend ?? this.moodTrend,
      weeklyInsightSummary: weeklyInsightSummary ?? this.weeklyInsightSummary,
      moodLogsCount: moodLogsCount ?? this.moodLogsCount,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      groundingSessionsCount: groundingSessionsCount ?? this.groundingSessionsCount,
      activeGroupsCount: activeGroupsCount ?? this.activeGroupsCount,
      nextSessionDate: nextSessionDate ?? this.nextSessionDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final profileHubProvider = Provider<ProfileHubState>((ref) {
  final authStatus = ref.watch(authProvider.select((state) => state.status));
  
  if (authStatus == AuthStatus.unauthenticated) {
    return const ProfileHubState(
      identityLine: "Your journey awaits.",
      growthScore: 0,
      growthDelta: 0,
      habitConsistency: 0,
      recoveryScore: 0,
      moodTrend: 'Stable',
      moodLogsCount: 0,
      focusMinutes: 0,
      groundingSessionsCount: 0,
      activeGroupsCount: 0,
      isLoading: false,
    );
  }

  // Use select where possible, but for AsyncValues it's often simpler to watch the whole thing 
  // or select specific properties if they update frequently.
  final cmhiAsync = ref.watch(latestCMHIProvider);
  final habitsAsync = ref.watch(todayHabitsProvider);
  final moodWidgetAsync = ref.watch(moodHomeWidgetProvider);
  final recoveryAsync = ref.watch(recoveryEffectivenessProvider(30));
  final challengeAsync = ref.watch(activeChallengeProvider);
  final weeklyInsightsAsync = ref.watch(weeklyInsightsProvider(7));
  final moodAnalyticsAsync = ref.watch(moodAnalyticsSummaryProvider(30)); // 30 days summary
  final focusAsync = ref.watch(focusProvider);
  final groundingAsync = ref.watch(groundingAnalyticsProvider);
  final groupsAsync = ref.watch(myGroupsProvider);
  final sessionsAsync = ref.watch(userSessionsProvider);
  final growthSummaryAsync = ref.watch(growthSummaryProvider);

  final isLoading = cmhiAsync.isLoading || habitsAsync.isLoading || moodWidgetAsync.isLoading || recoveryAsync.isLoading || weeklyInsightsAsync.isLoading || growthSummaryAsync.isLoading;

  if (isLoading) {
    return const ProfileHubState(
      identityLine: "Analyzing your recent progress...",
      growthScore: 0,
      growthDelta: 0,
      habitConsistency: 0,
      recoveryScore: 0,
      moodTrend: 'Stable',
      moodLogsCount: 0,
      focusMinutes: 0,
      groundingSessionsCount: 0,
      activeGroupsCount: 0,
      isLoading: true,
    );
  }

  // --- 1. Habit Consistency (0.0 - 1.0) ---
  final habits = habitsAsync.value ?? [];
  double habitConsistency = 0.0;
  if (habits.isNotEmpty) {
    int completed = habits.where((h) => h.logs.isNotEmpty).length;
    habitConsistency = completed / habits.length;
  } else {
    habitConsistency = 1.0; // No penalty for having no habits
  }

  // --- 2. Mood Stability (0.0 - 1.0) ---
  final moodWidget = moodWidgetAsync.value;
  double moodStability = 0.5; // Default middle
  String moodTrend = 'Stable';
  
  if (moodWidget != null) {
    // Basic heuristic based on streaks for stability
    final streak = moodWidget.streaks.dailyCheckin;
    moodStability = (streak / 7.0).clamp(0.0, 1.0);
    
    if (moodWidget.insightMessage.toLowerCase().contains('decline') || moodWidget.insightMessage.toLowerCase().contains('tough')) {
      moodTrend = 'Declining';
      moodStability *= 0.5; // Penalize stability if declining
    } else if (moodWidget.insightMessage.toLowerCase().contains('improv') || moodWidget.insightMessage.toLowerCase().contains('great')) {
      moodTrend = 'Improving';
      moodStability = (moodStability + 0.5).clamp(0.0, 1.0);
    }
  }

  // --- 3. Recovery Score (0.0 - 100.0) ---
  final recovery = recoveryAsync.value;
  // Note: RecoveryEffectiveness model doesn't have a single 'score' field, 
  // using 50 as default or derived from tools effectiveness.
  double recoveryScore = 50.0;
  if (recovery != null && recovery.tools.isNotEmpty) {
    recoveryScore = recovery.tools.map((t) => t.helpedPercent).reduce((a, b) => a + b) / recovery.tools.length;
  }

  // --- 4. Engagement Score (0.0 - 1.0) ---
  // Simple heuristic: Are they logging things?
  double engagementScore = 0.0;
  if (moodWidget?.hasLogs == true) engagementScore += 0.5;
  if (habits.isNotEmpty && habitConsistency > 0) engagementScore += 0.5;
  if (engagementScore == 0.0) engagementScore = 0.2; // Baseline for opening app

  // --- 5. Challenge Progress (0.0 - 1.0) ---
  final challenge = challengeAsync.value;
  double challengeProgress = challenge?.completionRate ?? 0.0;
  if (challenge == null) challengeProgress = 1.0; // No penalty

  // --- CALCULATE GROWTH SCORE (0 - 100) ---
  /*
    Growth Score Formula:
    Score = (Habit Consistency * 0.3) +
            (Mood Stability * 0.25) +
            (Recovery Score * 0.2) +
            (Engagement Score * 0.15) +
            (Challenge Progress * 0.1)
  */
  double score = (habitConsistency * 100 * 0.3) +
                 (moodStability * 100 * 0.25) +
                 (recoveryScore * 0.2) +
                 (engagementScore * 100 * 0.15) +
                 (challengeProgress * 100 * 0.1);
                 
  score = score.clamp(0.0, 100.0);

  // --- IDENTITY LINE GENERATION (Max 1 sentence) ---
  String identityLine = "You are actively shaping your mental resilience.";
  
  final riskLevel = cmhiAsync.value?.riskCategory;
  bool isHighRisk = riskLevel == RiskCategory.high || riskLevel == RiskCategory.severe || riskLevel == RiskCategory.emergency;

  if (isHighRisk || moodTrend == 'Declining') {
    // Encouraging
    if (habitConsistency > 0.5) {
      identityLine = "You're building consistency even on tough days.";
    } else {
      identityLine = "Your mental safety is the priority right now; take it one step at a time.";
    }
  } else if (moodTrend == 'Improving') {
    // Motivating
    identityLine = "Your recent efforts are showing real, measurable progress.";
  } else {
    // Reflective / Stable / Score Based
    if (score >= 80) {
      identityLine = "You've established a strong, sustainable foundation for growth.";
    } else if (score >= 60) {
      identityLine = "You are maintaining your balance and staying grounded.";
    } else if (score >= 30) {
      identityLine = "You're finding your footing. Small steps build momentum.";
    } else {
      identityLine = "Your energy is low right now. Be gentle with yourself.";
    }
  }

  return ProfileHubState(
    identityLine: identityLine,
    growthScore: score,
    growthDelta: growthSummaryAsync.value?['delta']?.toDouble() ?? 0.0,
    latestCMHI: cmhiAsync.value,
    habitConsistency: habitConsistency,
    recoveryScore: recoveryScore,
    moodTrend: moodTrend,
    weeklyInsightSummary: weeklyInsightsAsync.value?.insights.firstOrNull?.title,
    moodLogsCount: moodAnalyticsAsync.value?.totalLogs ?? 0,
    focusMinutes: focusAsync.stats?.totalMinutes ?? 0,
    groundingSessionsCount: groundingAsync.value?.weeklySessions ?? 0,
    activeGroupsCount: groupsAsync.value?.length ?? 0,
    nextSessionDate: sessionsAsync.value?['upcoming']?.firstOrNull?.date,
    isLoading: false,
  );
});
