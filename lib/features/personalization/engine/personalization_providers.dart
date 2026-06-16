import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/emotional_profile.dart';

// ==========================================
// PERSONALIZATION ORCHESTRATION LAYER
// ==========================================

/// Central provider for the emotional profile.
/// In production, this would be hydrated from backend analytics.
/// For now it provides a reactive profile that the entire app can consume.
final emotionalProfileProvider = NotifierProvider<EmotionalProfileNotifier, EmotionalProfile>(
  EmotionalProfileNotifier.new,
);

class EmotionalProfileNotifier extends Notifier<EmotionalProfile> {
  @override
  EmotionalProfile build() => const EmotionalProfile();

  void updateStress(int level) {
    state = EmotionalProfile(
      primaryTendency: state.primaryTendency,
      stressLevel: level.clamp(1, 5),
      energyLevel: state.energyLevel,
      sleepQuality: state.sleepQuality,
      recoveryState: state.recoveryState,
      stimulationTolerance: state.stimulationTolerance,
      preferredTools: state.preferredTools,
      calmingBehaviors: state.calmingBehaviors,
      timePattern: state.timePattern,
    );
  }

  void updateEnergy(int level) {
    state = EmotionalProfile(
      primaryTendency: state.primaryTendency,
      stressLevel: state.stressLevel,
      energyLevel: level.clamp(1, 5),
      sleepQuality: state.sleepQuality,
      recoveryState: state.recoveryState,
      stimulationTolerance: state.stimulationTolerance,
      preferredTools: state.preferredTools,
      calmingBehaviors: state.calmingBehaviors,
      timePattern: state.timePattern,
    );
  }

  void updateSleep(SleepQuality quality) {
    state = EmotionalProfile(
      primaryTendency: state.primaryTendency,
      stressLevel: state.stressLevel,
      energyLevel: state.energyLevel,
      sleepQuality: quality,
      recoveryState: state.recoveryState,
      stimulationTolerance: state.stimulationTolerance,
      preferredTools: state.preferredTools,
      calmingBehaviors: state.calmingBehaviors,
      timePattern: state.timePattern,
    );
  }

  void updateRecoveryState(RecoveryState recoveryState) {
    state = EmotionalProfile(
      primaryTendency: state.primaryTendency,
      stressLevel: state.stressLevel,
      energyLevel: state.energyLevel,
      sleepQuality: state.sleepQuality,
      recoveryState: recoveryState,
      stimulationTolerance: state.stimulationTolerance,
      preferredTools: state.preferredTools,
      calmingBehaviors: state.calmingBehaviors,
      timePattern: state.timePattern,
    );
  }

  void updateTendency(EmotionalTendency tendency) {
    state = EmotionalProfile(
      primaryTendency: tendency,
      stressLevel: state.stressLevel,
      energyLevel: state.energyLevel,
      sleepQuality: state.sleepQuality,
      recoveryState: state.recoveryState,
      stimulationTolerance: state.stimulationTolerance,
      preferredTools: state.preferredTools,
      calmingBehaviors: state.calmingBehaviors,
      timePattern: state.timePattern,
    );
  }

  void recordToolUsage(String route) {
    final tools = List<String>.from(state.preferredTools);
    if (!tools.contains(route)) {
      tools.add(route);
    }
    state = EmotionalProfile(
      primaryTendency: state.primaryTendency,
      stressLevel: state.stressLevel,
      energyLevel: state.energyLevel,
      sleepQuality: state.sleepQuality,
      recoveryState: state.recoveryState,
      stimulationTolerance: state.stimulationTolerance,
      preferredTools: tools,
      calmingBehaviors: state.calmingBehaviors,
      timePattern: state.timePattern,
    );
  }
}

/// Derived providers that any screen can consume.

final adaptiveUIModeProvider = Provider<AdaptiveUIMode>((ref) {
  return ref.watch(emotionalProfileProvider).uiMode;
});

final adaptiveUIConfigProvider = Provider<AdaptiveUIConfig>((ref) {
  final mode = ref.watch(adaptiveUIModeProvider);
  return AdaptiveUIConfig.fromMode(mode);
});

final novaToneProvider = Provider<NovaTone>((ref) {
  return ref.watch(emotionalProfileProvider).novaTone;
});

final novaAdaptiveConfigProvider = Provider<NovaAdaptiveConfig>((ref) {
  final tone = ref.watch(novaToneProvider);
  return NovaAdaptiveConfig.fromTone(tone);
});

final emotionalRecommendationsProvider = Provider<List<EmotionalRecommendation>>((ref) {
  final profile = ref.watch(emotionalProfileProvider);
  return RecommendationEngine.fromProfile(profile);
});

final journeyPacingProvider = Provider<String>((ref) {
  final profile = ref.watch(emotionalProfileProvider);
  return AdaptiveJourneyPacing.getPacingAdvice(profile);
});

final journeyRecommendedStepsProvider = Provider<int>((ref) {
  final profile = ref.watch(emotionalProfileProvider);
  return AdaptiveJourneyPacing.getRecommendedSteps(profile);
});

/// Emotional memory settings provider.
final emotionalMemorySettingsProvider = NotifierProvider<EmotionalMemorySettingsNotifier, EmotionalMemorySettings>(
  EmotionalMemorySettingsNotifier.new,
);

class EmotionalMemorySettingsNotifier extends Notifier<EmotionalMemorySettings> {
  @override
  EmotionalMemorySettings build() => const EmotionalMemorySettings();
  
  void update(EmotionalMemorySettings newSettings) {
    state = newSettings;
  }
}
