import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

// ==========================================
// SAFE SUPPORT SPACES (Groups)
// ==========================================

class SafeGroup {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int memberCount;
  final bool isModerated;

  const SafeGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.memberCount = 0,
    this.isModerated = true,
  });
}

class SafeGroups {
  SafeGroups._();

  static const List<SafeGroup> all = [
    SafeGroup(
      id: 'anxiety',
      title: 'Anxiety Support',
      description: 'For those navigating worry and fear',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
    ),
    SafeGroup(
      id: 'burnout',
      title: 'Burnout Recovery',
      description: 'Rebuilding from exhaustion together',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.warmSupport,
    ),
    SafeGroup(
      id: 'adhd',
      title: 'ADHD Support',
      description: 'Managing focus and overwhelm',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurple,
    ),
    SafeGroup(
      id: 'sleep',
      title: 'Sleep Recovery',
      description: 'Healing rest together',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
    ),
    SafeGroup(
      id: 'emotional_healing',
      title: 'Emotional Healing',
      description: 'Processing and growing',
      icon: Icons.favorite_rounded,
      color: AppColors.warmSupport,
    ),
    SafeGroup(
      id: 'young_adult',
      title: 'Young Adult Support',
      description: 'Navigating early adulthood',
      icon: Icons.psychology_rounded,
      color: AppColors.novaPurpleLight,
    ),
    SafeGroup(
      id: 'overthinking',
      title: 'Overthinking Recovery',
      description: 'Quieting the busy mind',
      icon: Icons.cloud_rounded,
      color: AppColors.calmTeal,
    ),
    SafeGroup(
      id: 'mens_support',
      title: "Men's Emotional Support",
      description: 'A safe space for men to feel',
      icon: Icons.shield_rounded,
      color: AppColors.recoveryBlue,
    ),
    SafeGroup(
      id: 'womens_healing',
      title: "Women's Emotional Healing",
      description: 'Strength through vulnerability',
      icon: Icons.spa_rounded,
      color: AppColors.novaPurpleLight,
    ),
  ];
}

// ==========================================
// LIVE CIRCLES
// ==========================================

class LiveCircleType {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String hostType; // 'therapist', 'peer', 'nova'

  const LiveCircleType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.hostType,
  });
}

class LiveCircleTypes {
  LiveCircleTypes._();

  static const List<LiveCircleType> all = [
    LiveCircleType(
      id: 'quiet_reflection',
      title: 'Quiet Reflection',
      description: 'Silent presence, shared calm',
      icon: Icons.self_improvement_rounded,
      color: AppColors.calmTeal,
      hostType: 'peer',
    ),
    LiveCircleType(
      id: 'night_calm',
      title: 'Night Calm',
      description: 'Winding down together',
      icon: Icons.nightlight_round,
      color: AppColors.recoveryBlue,
      hostType: 'peer',
    ),
    LiveCircleType(
      id: 'anxiety_reset',
      title: 'Anxiety Reset',
      description: 'Guided breathing in community',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
      hostType: 'therapist',
    ),
    LiveCircleType(
      id: 'burnout_recovery',
      title: 'Burnout Recovery',
      description: 'Healing exhaustion together',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.warmSupport,
      hostType: 'therapist',
    ),
    LiveCircleType(
      id: 'emotional_release',
      title: 'Emotional Release',
      description: 'Let it out safely',
      icon: Icons.water_drop_rounded,
      color: AppColors.novaPurple,
      hostType: 'therapist',
    ),
    LiveCircleType(
      id: 'adhd_calm',
      title: 'ADHD Calm Space',
      description: 'Structured gentleness',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurpleLight,
      hostType: 'peer',
    ),
  ];
}

// ==========================================
// EMOTIONAL REACTIONS (replace likes)
// ==========================================

class EmotionalReaction {
  final String id;
  final String label;
  final String emoji;

  const EmotionalReaction({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

class EmotionalReactions {
  EmotionalReactions._();

  static const List<EmotionalReaction> all = [
    EmotionalReaction(id: 'feel_this', label: 'I Feel This Too', emoji: '💙'),
    EmotionalReaction(id: 'support', label: 'Sending Support', emoji: '🤗'),
    EmotionalReaction(id: 'strength', label: 'You Are Strong', emoji: '💪'),
    EmotionalReaction(id: 'peace', label: 'Sending Peace', emoji: '🕊️'),
    EmotionalReaction(id: 'not_alone', label: 'You\'re Not Alone', emoji: '🫂'),
  ];
}

// ==========================================
// COMMUNITY GUIDELINES
// ==========================================

class CommunityGuidelines {
  CommunityGuidelines._();

  static const List<String> safetyRules = [
    'This space is judgment-free.',
    'Your identity is protected.',
    'You can participate at your own pace.',
    'Silence is welcome. Listening counts.',
    'Support, not advice. We hold, not fix.',
    "What's shared here stays here.",
  ];

  static const List<String> emptyStateMessages = [
    "You're not alone here.",
    'Others may understand this feeling too.',
    'You can participate at your own pace.',
    'This is a space for healing, not performance.',
    'Sometimes being present is enough.',
  ];

  static String getEmptyState() {
    final list = List<String>.from(emptyStateMessages)..shuffle();
    return list.first;
  }
}
