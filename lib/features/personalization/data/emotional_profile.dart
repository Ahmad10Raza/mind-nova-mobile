import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

// ==========================================
// EMOTIONAL PROFILE
// ==========================================

/// The user's emotional profile — gradually built from behavior,
/// never harshly labeled, always respectful.
class EmotionalProfile {
  final EmotionalTendency primaryTendency;
  final int stressLevel; // 1-5
  final int energyLevel; // 1-5
  final SleepQuality sleepQuality;
  final RecoveryState recoveryState;
  final StimulationTolerance stimulationTolerance;
  final List<String> preferredTools; // tool route IDs
  final List<String> calmingBehaviors;
  final TimeOfDayPattern timePattern;

  const EmotionalProfile({
    this.primaryTendency = EmotionalTendency.balanced,
    this.stressLevel = 3,
    this.energyLevel = 3,
    this.sleepQuality = SleepQuality.moderate,
    this.recoveryState = RecoveryState.stable,
    this.stimulationTolerance = StimulationTolerance.normal,
    this.preferredTools = const [],
    this.calmingBehaviors = const [],
    this.timePattern = TimeOfDayPattern.neutral,
  });

  /// Derive the adaptive UI mode from the profile.
  AdaptiveUIMode get uiMode {
    if (stressLevel >= 4 || stimulationTolerance == StimulationTolerance.low) {
      return AdaptiveUIMode.calm;
    }
    if (recoveryState == RecoveryState.burnout || recoveryState == RecoveryState.exhausted) {
      return AdaptiveUIMode.recovery;
    }
    if (energyLevel >= 4 && stressLevel <= 2) {
      return AdaptiveUIMode.focused;
    }
    return AdaptiveUIMode.standard;
  }

  /// Derive Nova's communication style.
  NovaTone get novaTone {
    if (stressLevel >= 4) return NovaTone.grounding;
    if (primaryTendency == EmotionalTendency.reflective) return NovaTone.reflective;
    if (primaryTendency == EmotionalTendency.anxious) return NovaTone.calming;
    if (recoveryState == RecoveryState.burnout) return NovaTone.gentle;
    return NovaTone.warm;
  }
}

enum EmotionalTendency {
  balanced,
  anxious,
  reflective,
  overwhelmed,
  exhausted,
  hopeful,
}

enum SleepQuality { poor, moderate, good }

enum RecoveryState { stable, recovering, exhausted, burnout }

enum StimulationTolerance { low, normal, high }

enum TimeOfDayPattern { morningAnxiety, eveningStress, nightRestless, neutral }

// ==========================================
// ADAPTIVE UI MODES
// ==========================================

enum AdaptiveUIMode { standard, calm, recovery, focused }

class AdaptiveUIConfig {
  final bool reduceMotion;
  final bool reduceDensity;
  final double spacingMultiplier;
  final bool useCalmerGradients;
  final bool showBreathingPrompts;
  final int maxCardsPerSection;

  const AdaptiveUIConfig({
    this.reduceMotion = false,
    this.reduceDensity = false,
    this.spacingMultiplier = 1.0,
    this.useCalmerGradients = false,
    this.showBreathingPrompts = false,
    this.maxCardsPerSection = 6,
  });

  static AdaptiveUIConfig fromMode(AdaptiveUIMode mode) {
    switch (mode) {
      case AdaptiveUIMode.calm:
        return const AdaptiveUIConfig(
          reduceMotion: true,
          reduceDensity: true,
          spacingMultiplier: 1.3,
          useCalmerGradients: true,
          showBreathingPrompts: true,
          maxCardsPerSection: 3,
        );
      case AdaptiveUIMode.recovery:
        return const AdaptiveUIConfig(
          reduceMotion: true,
          reduceDensity: true,
          spacingMultiplier: 1.5,
          useCalmerGradients: true,
          showBreathingPrompts: true,
          maxCardsPerSection: 2,
        );
      case AdaptiveUIMode.focused:
        return const AdaptiveUIConfig(
          reduceMotion: false,
          reduceDensity: true,
          spacingMultiplier: 1.0,
          useCalmerGradients: false,
          showBreathingPrompts: false,
          maxCardsPerSection: 4,
        );
      case AdaptiveUIMode.standard:
        return const AdaptiveUIConfig();
    }
  }
}

// ==========================================
// NOVA ADAPTIVE TONE
// ==========================================

enum NovaTone { warm, calming, grounding, reflective, gentle }

class NovaAdaptiveConfig {
  final int maxResponseLength; // word target
  final bool preferShortResponses;
  final bool leadWithGrounding;
  final bool includeBreathingPrompt;
  final String openingStyle;

  const NovaAdaptiveConfig({
    this.maxResponseLength = 60,
    this.preferShortResponses = false,
    this.leadWithGrounding = false,
    this.includeBreathingPrompt = false,
    this.openingStyle = 'warm',
  });

  static NovaAdaptiveConfig fromTone(NovaTone tone) {
    switch (tone) {
      case NovaTone.calming:
        return const NovaAdaptiveConfig(
          maxResponseLength: 40,
          preferShortResponses: true,
          leadWithGrounding: true,
          includeBreathingPrompt: true,
          openingStyle: 'calming',
        );
      case NovaTone.grounding:
        return const NovaAdaptiveConfig(
          maxResponseLength: 30,
          preferShortResponses: true,
          leadWithGrounding: true,
          includeBreathingPrompt: true,
          openingStyle: 'grounding',
        );
      case NovaTone.reflective:
        return const NovaAdaptiveConfig(
          maxResponseLength: 80,
          preferShortResponses: false,
          leadWithGrounding: false,
          includeBreathingPrompt: false,
          openingStyle: 'reflective',
        );
      case NovaTone.gentle:
        return const NovaAdaptiveConfig(
          maxResponseLength: 40,
          preferShortResponses: true,
          leadWithGrounding: false,
          includeBreathingPrompt: true,
          openingStyle: 'gentle',
        );
      case NovaTone.warm:
        return const NovaAdaptiveConfig();
    }
  }
}

// ==========================================
// EMOTIONAL RECOMMENDATIONS
// ==========================================

class EmotionalRecommendation {
  final String title;
  final String reason;
  final String route;
  final IconData icon;
  final Color color;
  final RecommendationPriority priority;

  const EmotionalRecommendation({
    required this.title,
    required this.reason,
    required this.route,
    required this.icon,
    required this.color,
    this.priority = RecommendationPriority.normal,
  });
}

enum RecommendationPriority { gentle, normal, suggested }

class RecommendationEngine {
  RecommendationEngine._();

  /// Generate emotionally contextual recommendations from profile.
  static List<EmotionalRecommendation> fromProfile(EmotionalProfile profile) {
    final recs = <EmotionalRecommendation>[];

    // Stress-based
    if (profile.stressLevel >= 4) {
      recs.add(const EmotionalRecommendation(
        title: 'Breathing Exercise',
        reason: 'Your stress seems elevated. Breathing may help.',
        route: '/breathing',
        icon: Icons.air_rounded,
        color: AppColors.calmTeal,
        priority: RecommendationPriority.suggested,
      ));
    }

    // Sleep-based
    if (profile.sleepQuality == SleepQuality.poor) {
      recs.add(const EmotionalRecommendation(
        title: 'Sleep Recovery',
        reason: 'Poor sleep affects emotional balance. Let\'s support rest.',
        route: '/recovery',
        icon: Icons.bedtime_rounded,
        color: AppColors.recoveryBlue,
        priority: RecommendationPriority.suggested,
      ));
    }

    // Recovery state
    if (profile.recoveryState == RecoveryState.burnout) {
      recs.add(const EmotionalRecommendation(
        title: 'Safe Space',
        reason: 'Burnout needs low stimulation. This is a safe place.',
        route: '/safe-space',
        icon: Icons.shield_rounded,
        color: AppColors.recoveryBlue,
        priority: RecommendationPriority.suggested,
      ));
    }

    // Anxiety tendency
    if (profile.primaryTendency == EmotionalTendency.anxious) {
      recs.add(const EmotionalRecommendation(
        title: 'Grounding Exercise',
        reason: 'Grounding helps calm the nervous system.',
        route: '/grounding',
        icon: Icons.spa_rounded,
        color: AppColors.calmTeal,
      ));
    }

    // Low energy
    if (profile.energyLevel <= 2) {
      recs.add(const EmotionalRecommendation(
        title: 'Recovery Mode',
        reason: 'Low energy days need gentle support.',
        route: '/recovery',
        icon: Icons.self_improvement_rounded,
        color: AppColors.recoveryBlue,
      ));
    }

    // Time-based
    final hour = DateTime.now().hour;
    if (hour >= 21 || hour < 5) {
      recs.add(const EmotionalRecommendation(
        title: 'Calm Sounds',
        reason: 'Night time. Calming sounds may help you wind down.',
        route: '/audio',
        icon: Icons.music_note_rounded,
        color: AppColors.novaPurple,
        priority: RecommendationPriority.gentle,
      ));
    }

    // Preferred tools reminder
    if (profile.preferredTools.contains('/journal')) {
      recs.add(const EmotionalRecommendation(
        title: 'Journal',
        reason: 'Journaling has helped you process emotions before.',
        route: '/journal',
        icon: Icons.edit_note_rounded,
        color: AppColors.novaPurple,
        priority: RecommendationPriority.gentle,
      ));
    }

    // Default gentle suggestion
    if (recs.isEmpty) {
      recs.add(const EmotionalRecommendation(
        title: 'Check-in With Yourself',
        reason: 'A moment of emotional awareness goes a long way.',
        route: '/mood-checkin',
        icon: Icons.favorite_rounded,
        color: AppColors.warmSupport,
        priority: RecommendationPriority.gentle,
      ));
    }

    // Sort: suggested first, then normal, then gentle
    recs.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return recs.take(3).toList(); // max 3 recommendations
  }
}

// ==========================================
// EMOTIONAL MEMORY (Privacy-First)
// ==========================================

class EmotionalMemory {
  final List<String> preferredTools;
  final List<String> calmingBehaviors;
  final String? preferredBreathingPattern;
  final String? preferredRecoveryMode;
  final bool hasCompletedJourney;
  final int journeyPauseCount;

  const EmotionalMemory({
    this.preferredTools = const [],
    this.calmingBehaviors = const [],
    this.preferredBreathingPattern,
    this.preferredRecoveryMode,
    this.hasCompletedJourney = false,
    this.journeyPauseCount = 0,
  });
}

class EmotionalMemorySettings {
  final bool rememberPreferredTools;
  final bool rememberCalmingBehaviors;
  final bool rememberRecoveryPreferences;
  final bool allowAdaptiveUI;
  final bool allowNovaAdaptation;

  const EmotionalMemorySettings({
    this.rememberPreferredTools = true,
    this.rememberCalmingBehaviors = true,
    this.rememberRecoveryPreferences = true,
    this.allowAdaptiveUI = true,
    this.allowNovaAdaptation = true,
  });
}

// ==========================================
// ADAPTIVE JOURNEY PACING
// ==========================================

class AdaptiveJourneyPacing {
  AdaptiveJourneyPacing._();

  static String getPacingAdvice(EmotionalProfile profile) {
    if (profile.recoveryState == RecoveryState.burnout) {
      return 'Take it very slow today. One step is enough.';
    }
    if (profile.stressLevel >= 4) {
      return 'High stress detected. Consider pausing your journey today.';
    }
    if (profile.energyLevel <= 2) {
      return 'Low energy. Maybe just breathing today.';
    }
    if (profile.sleepQuality == SleepQuality.poor) {
      return 'Poor sleep affects healing. Rest first, journey second.';
    }
    return 'You seem ready for today\'s steps. Go at your own pace.';
  }

  static int getRecommendedSteps(EmotionalProfile profile) {
    if (profile.recoveryState == RecoveryState.burnout) return 1;
    if (profile.stressLevel >= 4) return 1;
    if (profile.energyLevel <= 2) return 2;
    return 3; // all steps
  }
}
