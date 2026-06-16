import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

// ==========================================
// EMOTIONAL STATES
// ==========================================

class EmotionalState {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final String category; // positive, neutral, difficult, critical
  final String novaResponse;
  final String? recoveryRoute;

  const EmotionalState({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.novaResponse,
    this.recoveryRoute,
  });
}

class EmotionalStates {
  EmotionalStates._();

  static const List<EmotionalState> all = [
    // ── Positive ────────────────────────
    EmotionalState(
      id: 'calm',
      label: 'Calm',
      description: 'Peaceful and settled',
      icon: Icons.water_drop_rounded,
      color: AppColors.calmTeal,
      category: 'positive',
      novaResponse: "That's a lovely place to be. Enjoy this moment.",
    ),
    EmotionalState(
      id: 'hopeful',
      label: 'Hopeful',
      description: 'Looking forward to something',
      icon: Icons.wb_sunny_rounded,
      color: AppColors.warmSupport,
      category: 'positive',
      novaResponse: "Hope is a quiet kind of strength. Hold onto it.",
    ),
    EmotionalState(
      id: 'grounded',
      label: 'Grounded',
      description: 'Centered and present',
      icon: Icons.spa_rounded,
      color: AppColors.calmTeal,
      category: 'positive',
      novaResponse: "Feeling grounded takes practice. You're doing it.",
    ),

    // ── Neutral ─────────────────────────
    EmotionalState(
      id: 'reflective',
      label: 'Reflective',
      description: 'Thinking things through',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.novaPurple,
      category: 'neutral',
      novaResponse: "Reflection is how we understand ourselves better.",
    ),
    EmotionalState(
      id: 'numb',
      label: 'Emotionally Numb',
      description: 'Disconnected from feelings',
      icon: Icons.cloud_rounded,
      color: AppColors.textMuted,
      category: 'neutral',
      novaResponse: "Numbness is your mind's way of protecting itself. That's okay.",
      recoveryRoute: '/grounding',
    ),

    // ── Difficult ───────────────────────
    EmotionalState(
      id: 'anxious',
      label: 'Anxious',
      description: 'Worried or on edge',
      icon: Icons.air_rounded,
      color: AppColors.warmSupport,
      category: 'difficult',
      novaResponse: "Anxiety is uncomfortable but it will pass. Let's breathe.",
      recoveryRoute: '/breathing',
    ),
    EmotionalState(
      id: 'overwhelmed',
      label: 'Overwhelmed',
      description: 'Too much at once',
      icon: Icons.waves_rounded,
      color: AppColors.emotionalWarning,
      category: 'difficult',
      novaResponse: "You don't need to solve everything right now. One thing at a time.",
      recoveryRoute: '/grounding',
    ),
    EmotionalState(
      id: 'drained',
      label: 'Emotionally Drained',
      description: 'Running on empty',
      icon: Icons.battery_1_bar_rounded,
      color: AppColors.recoveryBlue,
      category: 'difficult',
      novaResponse: "You've been carrying a lot. Rest is not weakness.",
      recoveryRoute: '/recovery',
    ),
    EmotionalState(
      id: 'lonely',
      label: 'Lonely',
      description: 'Feeling disconnected',
      icon: Icons.person_outline_rounded,
      color: AppColors.novaPurpleLight,
      category: 'difficult',
      novaResponse: "Loneliness is painful. I'm here with you right now.",
      recoveryRoute: '/community',
    ),
    EmotionalState(
      id: 'exhausted',
      label: 'Emotionally Exhausted',
      description: 'Completely spent',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.emotionalDangerMuted,
      category: 'difficult',
      novaResponse: "Exhaustion means you've been giving too much. Let's restore.",
      recoveryRoute: '/recovery',
    ),

    // ── Critical ────────────────────────
    EmotionalState(
      id: 'overloaded',
      label: 'Emotionally Overloaded',
      description: 'Beyond capacity',
      icon: Icons.error_outline_rounded,
      color: AppColors.emotionalDangerMuted,
      category: 'critical',
      novaResponse: "This sounds really heavy. Let me guide you to something calming.",
      recoveryRoute: '/crisis-support',
    ),
  ];

  static List<EmotionalState> byCategory(String category) {
    return all.where((s) => s.category == category).toList();
  }
}

// ==========================================
// REFLECTION PROMPTS
// ==========================================

class ReflectionPrompt {
  final String text;
  final String category; // morning, evening, emotional, general

  const ReflectionPrompt({required this.text, required this.category});
}

class ReflectionPrompts {
  ReflectionPrompts._();

  static const List<ReflectionPrompt> all = [
    // Morning
    ReflectionPrompt(text: 'How does your body feel right now?', category: 'morning'),
    ReflectionPrompt(text: 'What is one kind thing you can do for yourself today?', category: 'morning'),
    ReflectionPrompt(text: 'What emotion is present when you woke up?', category: 'morning'),

    // Evening
    ReflectionPrompt(text: 'What felt heavy today?', category: 'evening'),
    ReflectionPrompt(text: 'What small moment brought you peace?', category: 'evening'),
    ReflectionPrompt(text: 'What do you need to let go of before sleep?', category: 'evening'),

    // Emotional
    ReflectionPrompt(text: 'What are you feeling right now, without judging it?', category: 'emotional'),
    ReflectionPrompt(text: 'Where in your body do you feel this emotion?', category: 'emotional'),
    ReflectionPrompt(text: 'What would you say to a friend feeling this way?', category: 'emotional'),

    // General
    ReflectionPrompt(text: 'What is one thing you are grateful for right now?', category: 'general'),
    ReflectionPrompt(text: 'How has your energy been this week?', category: 'general'),
    ReflectionPrompt(text: 'What emotion has visited you most this week?', category: 'general'),
  ];

  static ReflectionPrompt forTimeOfDay() {
    final hour = DateTime.now().hour;
    final category = hour < 12 ? 'morning' : hour > 18 ? 'evening' : 'general';
    final prompts = all.where((p) => p.category == category).toList();
    prompts.shuffle();
    return prompts.first;
  }
}

// ==========================================
// MOOD CORRELATION INSIGHTS
// ==========================================

class EmotionalCorrelation {
  final String insight;
  final IconData icon;
  final Color color;

  const EmotionalCorrelation({
    required this.insight,
    required this.icon,
    required this.color,
  });
}

class EmotionalCorrelations {
  EmotionalCorrelations._();

  // These are example static insights; in production these would
  // come from the backend analytics engine.
  static const List<EmotionalCorrelation> examples = [
    EmotionalCorrelation(
      insight: 'Poor sleep often increases anxiety the next day.',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
    ),
    EmotionalCorrelation(
      insight: 'Breathing sessions improve your emotional recovery.',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
    ),
    EmotionalCorrelation(
      insight: 'Journaling improves your emotional clarity.',
      icon: Icons.edit_note_rounded,
      color: AppColors.novaPurple,
    ),
    EmotionalCorrelation(
      insight: 'Morning walks improve emotional stability.',
      icon: Icons.directions_walk_rounded,
      color: AppColors.warmSupport,
    ),
  ];
}
