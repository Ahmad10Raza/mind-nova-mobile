import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/gradients/app_gradients.dart';

// ==========================================
// EMOTIONAL CATEGORIES
// ==========================================

class ExploreCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;
  final List<String> routes;

  const ExploreCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.routes,
  });
}

class ExploreCategories {
  ExploreCategories._();

  static const List<ExploreCategory> all = [
    ExploreCategory(
      id: 'calm_mind',
      title: 'Calm Mind',
      description: 'Find peace and reduce anxiety',
      icon: Icons.spa_rounded,
      gradient: AppGradients.calm,
      accentColor: AppColors.calmTeal,
      routes: ['/breathing', '/grounding', '/meditation', '/recovery'],
    ),
    ExploreCategory(
      id: 'recovery_sleep',
      title: 'Recovery & Sleep',
      description: 'Rest, restore, and reset',
      icon: Icons.bedtime_rounded,
      gradient: AppGradients.sleep,
      accentColor: AppColors.recoveryBlue,
      routes: ['/sleep', '/audio', '/recovery'],
    ),
    ExploreCategory(
      id: 'focus_clarity',
      title: 'Focus & Clarity',
      description: 'Concentrate and stay present',
      icon: Icons.center_focus_strong_rounded,
      gradient: AppGradients.focus,
      accentColor: AppColors.novaPurple,
      routes: ['/focus', '/challenges', '/habits'],
    ),
    ExploreCategory(
      id: 'emotional_healing',
      title: 'Emotional Healing',
      description: 'Process, reflect, and grow',
      icon: Icons.favorite_rounded,
      gradient: AppGradients.therapy,
      accentColor: AppColors.warmSupport,
      routes: ['/journal', '/gratitude', '/mood-checkin', '/ai-reports'],
    ),
    ExploreCategory(
      id: 'community_support',
      title: 'Community & Support',
      description: 'Connect, share, and belong',
      icon: Icons.people_rounded,
      gradient: AppGradients.community,
      accentColor: AppColors.warmSupport,
      routes: ['/community', '/groups', '/chat'],
    ),
    ExploreCategory(
      id: 'professional_help',
      title: 'Professional Help',
      description: 'Get expert support when needed',
      icon: Icons.health_and_safety_rounded,
      gradient: AppGradients.recovery,
      accentColor: AppColors.recoveryBlue,
      routes: ['/therapist', '/assessment', '/crisis-hub'],
    ),
  ];
}

// ==========================================
// GUIDED JOURNEYS
// ==========================================

class GuidedJourney {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color color;
  final List<String> toolRoutes;

  const GuidedJourney({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
    required this.toolRoutes,
  });
}

class GuidedJourneys {
  GuidedJourneys._();

  static const List<GuidedJourney> all = [
    GuidedJourney(
      title: 'Anxiety Reset',
      subtitle: 'Breathe, ground, reflect',
      duration: '~15 min',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
      toolRoutes: ['/breathing', '/grounding', '/journal', '/mood-checkin'],
    ),
    GuidedJourney(
      title: 'Burnout Recovery',
      subtitle: 'Meditate, appreciate, rest',
      duration: '~20 min',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.warmSupport,
      toolRoutes: ['/meditation', '/gratitude', '/sleep'],
    ),
    GuidedJourney(
      title: 'Sleep Repair',
      subtitle: 'Sounds, breathing, log',
      duration: '~10 min',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
      toolRoutes: ['/audio', '/breathing', '/sleep'],
    ),
    GuidedJourney(
      title: 'Focus Recovery',
      subtitle: 'Timer, ground, habit check',
      duration: '~15 min',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurple,
      toolRoutes: ['/focus', '/grounding', '/habits'],
    ),
    GuidedJourney(
      title: 'Emotional Healing',
      subtitle: 'Journal, affirm, talk to Nova',
      duration: '~20 min',
      icon: Icons.favorite_rounded,
      color: AppColors.emotionalDangerMuted,
      toolRoutes: ['/journal', '/gratitude', '/nova-chat'],
    ),
    GuidedJourney(
      title: 'Overthinking Reset',
      subtitle: 'Ground, breathe, meditate',
      duration: '~10 min',
      icon: Icons.psychology_rounded,
      color: AppColors.calmTeal,
      toolRoutes: ['/grounding', '/breathing', '/meditation'],
    ),
  ];
}

// ==========================================
// FEELING-BASED NAVIGATION
// ==========================================

class FeelingShortcut {
  final String label;
  final String route;
  final Color color;

  const FeelingShortcut({
    required this.label,
    required this.route,
    required this.color,
  });
}

class FeelingShortcuts {
  FeelingShortcuts._();

  static const List<FeelingShortcut> all = [
    FeelingShortcut(label: 'I feel anxious', route: '/breathing', color: AppColors.calmTeal),
    FeelingShortcut(label: "I can't sleep", route: '/sleep', color: AppColors.recoveryBlue),
    FeelingShortcut(label: 'I feel overwhelmed', route: '/grounding', color: AppColors.warmSupport),
    FeelingShortcut(label: 'I need focus', route: '/focus', color: AppColors.novaPurple),
    FeelingShortcut(label: 'I feel lonely', route: '/community', color: AppColors.emotionalWarning),
    FeelingShortcut(label: 'I need help', route: '/crisis-hub', color: AppColors.emotionalDangerMuted),
  ];
}
