import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

// ==========================================
// EMOTIONAL SUPPORT CATEGORIES
// ==========================================

class TherapySupportArea {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const TherapySupportArea({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TherapySupportAreas {
  TherapySupportAreas._();

  static const List<TherapySupportArea> all = [
    TherapySupportArea(
      id: 'anxiety',
      title: 'Anxiety Support',
      description: 'Calm the nervous system',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
    ),
    TherapySupportArea(
      id: 'burnout',
      title: 'Burnout Recovery',
      description: 'Rebuild from exhaustion',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.warmSupport,
    ),
    TherapySupportArea(
      id: 'adhd',
      title: 'ADHD Support',
      description: 'Manage focus & overwhelm',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurple,
    ),
    TherapySupportArea(
      id: 'relationships',
      title: 'Relationship Healing',
      description: 'Navigate emotional bonds',
      icon: Icons.favorite_rounded,
      color: AppColors.warmSupport,
    ),
    TherapySupportArea(
      id: 'emotional_regulation',
      title: 'Emotional Regulation',
      description: 'Understand & manage emotions',
      icon: Icons.water_drop_rounded,
      color: AppColors.calmTeal,
    ),
    TherapySupportArea(
      id: 'trauma',
      title: 'Trauma Support',
      description: 'Gentle healing guidance',
      icon: Icons.shield_rounded,
      color: AppColors.recoveryBlue,
    ),
    TherapySupportArea(
      id: 'sleep_stress',
      title: 'Sleep & Stress',
      description: 'Rest and recovery support',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
    ),
    TherapySupportArea(
      id: 'young_adult',
      title: 'Young Adult Support',
      description: 'Navigating growing up',
      icon: Icons.psychology_rounded,
      color: AppColors.novaPurpleLight,
    ),
  ];
}

// ==========================================
// HEALING JOURNEYS
// ==========================================

class HealingJourney {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color color;
  final List<HealingJourneyPhase> phases;

  const HealingJourney({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
    required this.phases,
  });
}

class HealingJourneyPhase {
  final String label;
  final String type; // 'therapy', 'nova', 'recovery', 'journal', 'mood'

  const HealingJourneyPhase({required this.label, required this.type});
}

class HealingJourneys {
  HealingJourneys._();

  static const List<HealingJourney> all = [
    HealingJourney(
      title: 'Anxiety Recovery',
      subtitle: 'Structured anxiety healing path',
      duration: '4–8 weeks',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
      phases: [
        HealingJourneyPhase(label: 'Therapy Session', type: 'therapy'),
        HealingJourneyPhase(label: 'Nova Reflection', type: 'nova'),
        HealingJourneyPhase(label: 'Breathing Practice', type: 'recovery'),
        HealingJourneyPhase(label: 'Mood Check-in', type: 'mood'),
      ],
    ),
    HealingJourney(
      title: 'Burnout Healing',
      subtitle: 'Restore from exhaustion',
      duration: '6–12 weeks',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.warmSupport,
      phases: [
        HealingJourneyPhase(label: 'Therapy Session', type: 'therapy'),
        HealingJourneyPhase(label: 'Recovery Mode', type: 'recovery'),
        HealingJourneyPhase(label: 'Journaling', type: 'journal'),
        HealingJourneyPhase(label: 'Nova Check-in', type: 'nova'),
      ],
    ),
    HealingJourney(
      title: 'Emotional Regulation',
      subtitle: 'Build emotional intelligence',
      duration: '4–8 weeks',
      icon: Icons.water_drop_rounded,
      color: AppColors.novaPurple,
      phases: [
        HealingJourneyPhase(label: 'Therapy Session', type: 'therapy'),
        HealingJourneyPhase(label: 'Mood Tracking', type: 'mood'),
        HealingJourneyPhase(label: 'Grounding', type: 'recovery'),
        HealingJourneyPhase(label: 'Reflection', type: 'journal'),
      ],
    ),
    HealingJourney(
      title: 'Sleep Recovery',
      subtitle: 'Heal sleep disruption',
      duration: '3–6 weeks',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
      phases: [
        HealingJourneyPhase(label: 'Therapy Session', type: 'therapy'),
        HealingJourneyPhase(label: 'Sleep Sounds', type: 'recovery'),
        HealingJourneyPhase(label: 'Breathing', type: 'recovery'),
        HealingJourneyPhase(label: 'Sleep Log', type: 'mood'),
      ],
    ),
  ];
}

// ==========================================
// WAITING ROOM CONTENT
// ==========================================

class WaitingRoomContent {
  WaitingRoomContent._();

  static const List<String> reassurances = [
    "You don't need to prepare perfectly.",
    "This space is for you.",
    "It's okay to not have the words yet.",
    "Your therapist is here to listen, not judge.",
    "Healing starts with showing up. You did that.",
    "Take a slow breath before we begin.",
  ];

  static const List<String> groundingPrompts = [
    "Notice your feet on the ground.",
    "Feel the weight of your body in the chair.",
    "Take 3 slow breaths.",
    "Name one thing you see around you.",
    "Relax your shoulders gently.",
  ];

  static String getReassurance() {
    final list = List<String>.from(reassurances)..shuffle();
    return list.first;
  }

  static String getGrounding() {
    final list = List<String>.from(groundingPrompts)..shuffle();
    return list.first;
  }
}

// ==========================================
// POST-SESSION AFTERCARE
// ==========================================

class AftercarePrompt {
  final String text;
  final IconData icon;
  final Color color;
  final String? route;

  const AftercarePrompt({
    required this.text,
    required this.icon,
    required this.color,
    this.route,
  });
}

class AftercarePrompts {
  AftercarePrompts._();

  static const List<AftercarePrompt> all = [
    AftercarePrompt(
      text: 'Journal your thoughts',
      icon: Icons.edit_note_rounded,
      color: AppColors.novaPurple,
      route: '/journal',
    ),
    AftercarePrompt(
      text: 'Take a grounding moment',
      icon: Icons.spa_rounded,
      color: AppColors.calmTeal,
      route: '/grounding',
    ),
    AftercarePrompt(
      text: 'Breathing exercise',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
      route: '/breathing',
    ),
    AftercarePrompt(
      text: 'Talk to Nova',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.novaPurple,
      route: '/nova-chat',
    ),
    AftercarePrompt(
      text: 'Rest in Safe Space',
      icon: Icons.shield_rounded,
      color: AppColors.recoveryBlue,
      route: '/safe-space',
    ),
  ];
}
