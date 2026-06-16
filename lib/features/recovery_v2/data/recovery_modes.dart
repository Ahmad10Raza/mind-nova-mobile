import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/gradients/app_gradients.dart';

// ==========================================
// RECOVERY MODES
// ==========================================

class RecoveryMode {
  final String id;
  final String title;
  final String subtitle;
  final String emotionalIntent;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;
  final List<String> toolRoutes;
  final String breathingPattern; // e.g. "4-7-8", "box", "slow"
  final Duration suggestedDuration;

  const RecoveryMode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emotionalIntent,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.toolRoutes,
    required this.breathingPattern,
    required this.suggestedDuration,
  });
}

class RecoveryModes {
  RecoveryModes._();

  static const List<RecoveryMode> all = [
    RecoveryMode(
      id: 'deep_calm',
      title: 'Deep Calm',
      subtitle: 'Anxiety relief & nervous system reset',
      emotionalIntent: 'Find stillness in the storm',
      icon: Icons.water_drop_rounded,
      gradient: AppGradients.calm,
      accentColor: AppColors.calmTeal,
      toolRoutes: ['/breathing', '/grounding', '/meditation'],
      breathingPattern: '4-7-8',
      suggestedDuration: Duration(minutes: 10),
    ),
    RecoveryMode(
      id: 'sleep_recovery',
      title: 'Sleep Recovery',
      subtitle: 'Bedtime support & emotional quieting',
      emotionalIntent: 'Prepare your mind for rest',
      icon: Icons.bedtime_rounded,
      gradient: AppGradients.sleep,
      accentColor: AppColors.recoveryBlue,
      toolRoutes: ['/audio', '/breathing', '/sleep'],
      breathingPattern: 'slow',
      suggestedDuration: Duration(minutes: 15),
    ),
    RecoveryMode(
      id: 'emotional_reset',
      title: 'Emotional Reset',
      subtitle: 'Overwhelm reduction & grounding',
      emotionalIntent: 'Release what you are carrying',
      icon: Icons.spa_rounded,
      gradient: AppGradients.therapy,
      accentColor: AppColors.warmSupport,
      toolRoutes: ['/grounding', '/journal', '/breathing'],
      breathingPattern: 'box',
      suggestedDuration: Duration(minutes: 10),
    ),
    RecoveryMode(
      id: 'burnout_recovery',
      title: 'Burnout Recovery',
      subtitle: 'Mental exhaustion & restoration',
      emotionalIntent: 'You have given enough. Rest now.',
      icon: Icons.local_fire_department_rounded,
      gradient: AppGradients.recovery,
      accentColor: AppColors.recoveryBlue,
      toolRoutes: ['/meditation', '/gratitude', '/audio'],
      breathingPattern: 'slow',
      suggestedDuration: Duration(minutes: 20),
    ),
    RecoveryMode(
      id: 'focus_recovery',
      title: 'Focus Recovery',
      subtitle: 'Cognitive reset & overstimulation relief',
      emotionalIntent: 'Quiet the noise gently',
      icon: Icons.center_focus_strong_rounded,
      gradient: AppGradients.focus,
      accentColor: AppColors.novaPurple,
      toolRoutes: ['/grounding', '/breathing', '/focus'],
      breathingPattern: 'box',
      suggestedDuration: Duration(minutes: 10),
    ),
  ];
}

// ==========================================
// GUIDED RECOVERY JOURNEYS
// ==========================================

class RecoveryJourney {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color color;
  final List<RecoveryJourneyStep> steps;

  const RecoveryJourney({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
    required this.steps,
  });
}

class RecoveryJourneyStep {
  final String label;
  final String route;
  final IconData icon;

  const RecoveryJourneyStep({
    required this.label,
    required this.route,
    required this.icon,
  });
}

class RecoveryJourneys {
  RecoveryJourneys._();

  static const List<RecoveryJourney> all = [
    RecoveryJourney(
      title: '5-Minute Reset',
      subtitle: 'Quick nervous system calm',
      duration: '~5 min',
      icon: Icons.timer_rounded,
      color: AppColors.calmTeal,
      steps: [
        RecoveryJourneyStep(label: 'Ground', route: '/grounding', icon: Icons.spa_rounded),
        RecoveryJourneyStep(label: 'Breathe', route: '/breathing', icon: Icons.air_rounded),
      ],
    ),
    RecoveryJourney(
      title: 'Sleep Repair',
      subtitle: 'Prepare body and mind for rest',
      duration: '~15 min',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
      steps: [
        RecoveryJourneyStep(label: 'Breathe', route: '/breathing', icon: Icons.air_rounded),
        RecoveryJourneyStep(label: 'Sounds', route: '/audio', icon: Icons.music_note_rounded),
        RecoveryJourneyStep(label: 'Log Sleep', route: '/sleep', icon: Icons.bedtime_rounded),
      ],
    ),
    RecoveryJourney(
      title: 'Overthinking Calm',
      subtitle: 'Slow the mental spiral',
      duration: '~10 min',
      icon: Icons.psychology_rounded,
      color: AppColors.warmSupport,
      steps: [
        RecoveryJourneyStep(label: 'Ground', route: '/grounding', icon: Icons.spa_rounded),
        RecoveryJourneyStep(label: 'Breathe', route: '/breathing', icon: Icons.air_rounded),
        RecoveryJourneyStep(label: 'Journal', route: '/journal', icon: Icons.edit_note_rounded),
      ],
    ),
    RecoveryJourney(
      title: 'Emotional Detox',
      subtitle: 'Release emotional weight',
      duration: '~15 min',
      icon: Icons.favorite_rounded,
      color: AppColors.novaPurple,
      steps: [
        RecoveryJourneyStep(label: 'Journal', route: '/journal', icon: Icons.edit_note_rounded),
        RecoveryJourneyStep(label: 'Breathe', route: '/breathing', icon: Icons.air_rounded),
        RecoveryJourneyStep(label: 'Reflect', route: '/gratitude', icon: Icons.auto_awesome_rounded),
      ],
    ),
    RecoveryJourney(
      title: 'Nervous System Reset',
      subtitle: 'Full decompression flow',
      duration: '~20 min',
      icon: Icons.water_drop_rounded,
      color: AppColors.calmTeal,
      steps: [
        RecoveryJourneyStep(label: 'Ground', route: '/grounding', icon: Icons.spa_rounded),
        RecoveryJourneyStep(label: 'Breathe', route: '/breathing', icon: Icons.air_rounded),
        RecoveryJourneyStep(label: 'Meditate', route: '/meditation', icon: Icons.self_improvement_rounded),
        RecoveryJourneyStep(label: 'Sounds', route: '/audio', icon: Icons.music_note_rounded),
      ],
    ),
  ];
}

// ==========================================
// RECOVERY AUDIO CATEGORIES
// ==========================================

class RecoveryAudioCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const RecoveryAudioCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class RecoveryAudioCategories {
  RecoveryAudioCategories._();

  static const List<RecoveryAudioCategory> all = [
    RecoveryAudioCategory(
      title: 'Deep Sleep',
      description: 'Drift into restful sleep',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
      route: '/audio',
    ),
    RecoveryAudioCategory(
      title: 'Calm Anxiety',
      description: 'Ease your nervous system',
      icon: Icons.water_drop_rounded,
      color: AppColors.calmTeal,
      route: '/audio',
    ),
    RecoveryAudioCategory(
      title: 'Focus Recovery',
      description: 'Reset cognitive overload',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurple,
      route: '/audio',
    ),
    RecoveryAudioCategory(
      title: 'Emotional Healing',
      description: 'Gentle restoration',
      icon: Icons.favorite_rounded,
      color: AppColors.warmSupport,
      route: '/audio',
    ),
    RecoveryAudioCategory(
      title: 'Safe Space',
      description: 'Minimal, calming ambient',
      icon: Icons.shield_rounded,
      color: AppColors.recoveryBlue,
      route: '/audio',
    ),
  ];
}

// ==========================================
// BREATHING PATTERNS
// ==========================================

class BreathingPattern {
  final String id;
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int? holdAfterExhale;
  final Color color;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.holdAfterExhale,
    required this.color,
  });

  int get totalCycleSeconds =>
      inhaleSeconds + holdSeconds + exhaleSeconds + (holdAfterExhale ?? 0);
}

class BreathingPatterns {
  BreathingPatterns._();

  static const BreathingPattern fourSevenEight = BreathingPattern(
    id: '4-7-8',
    name: '4-7-8 Calm',
    description: 'Deep anxiety relief',
    inhaleSeconds: 4,
    holdSeconds: 7,
    exhaleSeconds: 8,
    color: AppColors.calmTeal,
  );

  static const BreathingPattern boxBreathing = BreathingPattern(
    id: 'box',
    name: 'Box Breathing',
    description: 'Balanced nervous system reset',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    holdAfterExhale: 4,
    color: AppColors.novaPurple,
  );

  static const BreathingPattern slowBreathing = BreathingPattern(
    id: 'slow',
    name: 'Slow & Gentle',
    description: 'Bedtime calming rhythm',
    inhaleSeconds: 5,
    holdSeconds: 2,
    exhaleSeconds: 7,
    color: AppColors.recoveryBlue,
  );

  static const BreathingPattern panicReset = BreathingPattern(
    id: 'panic',
    name: 'Panic Reset',
    description: 'Emergency grounding breath',
    inhaleSeconds: 3,
    holdSeconds: 3,
    exhaleSeconds: 6,
    color: AppColors.emotionalDangerMuted,
  );

  static const List<BreathingPattern> all = [
    fourSevenEight,
    boxBreathing,
    slowBreathing,
    panicReset,
  ];

  static BreathingPattern fromId(String id) {
    return all.firstWhere((p) => p.id == id, orElse: () => slowBreathing);
  }
}
