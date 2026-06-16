import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

// ==========================================
// HEALING JOURNEY DEFINITIONS
// ==========================================

class HealingJourneyStep {
  final String title;
  final String description;
  final String type; // 'breathing', 'reflection', 'grounding', 'audio', 'journal', 'checkin', 'nova', 'habit'
  final IconData icon;
  final Duration estimatedDuration;
  final String? route;

  const HealingJourneyStep({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.estimatedDuration,
    this.route,
  });
}

class HealingJourneyDay {
  final int dayNumber;
  final String theme;
  final String emotionalIntent;
  final List<HealingJourneyStep> steps;

  const HealingJourneyDay({
    required this.dayNumber,
    required this.theme,
    required this.emotionalIntent,
    required this.steps,
  });
}

class GuidedHealingJourney {
  final String id;
  final String title;
  final String subtitle;
  final String emotionalIntent;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final String duration;
  final String difficulty; // 'gentle', 'moderate', 'deep'
  final bool isTherapistGuided;
  final List<String> tags;
  final List<HealingJourneyDay> days;

  const GuidedHealingJourney({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emotionalIntent,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.duration,
    required this.difficulty,
    this.isTherapistGuided = false,
    required this.tags,
    required this.days,
  });
}

// ==========================================
// CORE JOURNEYS
// ==========================================

class GuidedJourneys {
  GuidedJourneys._();

  static final List<GuidedHealingJourney> all = [
    // ── 1. Anxiety Reset ────────────────────
    GuidedHealingJourney(
      id: 'anxiety_reset',
      title: 'Anxiety Reset',
      subtitle: 'Calm your nervous system',
      emotionalIntent: 'From overwhelm to grounded safety',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
      gradient: const LinearGradient(
        colors: [Color(0xFF0D2B3E), Color(0xFF1A3A4A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '7 days',
      difficulty: 'gentle',
      tags: ['anxiety', 'breathing', 'grounding'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Understanding Your Anxiety',
          emotionalIntent: 'Meet your anxiety without judgment',
          steps: [
            HealingJourneyStep(title: 'Breathing', description: '4-7-8 calming breath', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
            HealingJourneyStep(title: 'Reflection', description: 'What does your anxiety feel like?', type: 'reflection', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 5)),
            HealingJourneyStep(title: 'Check-in', description: 'How are you feeling now?', type: 'checkin', icon: Icons.favorite_rounded, estimatedDuration: Duration(minutes: 2), route: '/mood-checkin'),
          ],
        ),
        const HealingJourneyDay(
          dayNumber: 2,
          theme: 'Grounding Your Body',
          emotionalIntent: 'Connect mind to body gently',
          steps: [
            HealingJourneyStep(title: 'Grounding', description: '5-4-3-2-1 senses exercise', type: 'grounding', icon: Icons.spa_rounded, estimatedDuration: Duration(minutes: 5), route: '/grounding'),
            HealingJourneyStep(title: 'Calm Sounds', description: 'Ocean waves or rain', type: 'audio', icon: Icons.music_note_rounded, estimatedDuration: Duration(minutes: 10), route: '/audio'),
            HealingJourneyStep(title: 'Nova Reflection', description: 'How does grounding feel?', type: 'nova', icon: Icons.auto_awesome_rounded, estimatedDuration: Duration(minutes: 5), route: '/nova-chat'),
          ],
        ),
        const HealingJourneyDay(
          dayNumber: 3,
          theme: 'Releasing Worry',
          emotionalIntent: 'Let anxious thoughts pass like clouds',
          steps: [
            HealingJourneyStep(title: 'Breathing', description: 'Box breathing for calm', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
            HealingJourneyStep(title: 'Journal', description: 'Write what worries you, then release', type: 'journal', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 10), route: '/journal'),
            HealingJourneyStep(title: 'Check-in', description: 'Emotional state after release', type: 'checkin', icon: Icons.favorite_rounded, estimatedDuration: Duration(minutes: 2), route: '/mood-checkin'),
          ],
        ),
      ],
    ),

    // ── 2. Burnout Recovery ─────────────────
    GuidedHealingJourney(
      id: 'burnout_recovery',
      title: 'Burnout Recovery',
      subtitle: 'Rebuild from exhaustion',
      emotionalIntent: 'From depletion to restored energy',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.warmSupport,
      gradient: const LinearGradient(
        colors: [Color(0xFF2D1B0E), Color(0xFF3A2515)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '14 days',
      difficulty: 'moderate',
      isTherapistGuided: true,
      tags: ['burnout', 'recovery', 'rest'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Permission to Rest',
          emotionalIntent: 'Rest is not weakness. It is healing.',
          steps: [
            HealingJourneyStep(title: 'Nova Check-in', description: "Let's understand your exhaustion", type: 'nova', icon: Icons.auto_awesome_rounded, estimatedDuration: Duration(minutes: 5), route: '/nova-chat'),
            HealingJourneyStep(title: 'Breathing', description: 'Slow & gentle breathing', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
            HealingJourneyStep(title: 'Reflection', description: 'What has been draining you?', type: 'reflection', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 5)),
          ],
        ),
        const HealingJourneyDay(
          dayNumber: 2,
          theme: 'Emotional Decompression',
          emotionalIntent: 'Release what you have been carrying',
          steps: [
            HealingJourneyStep(title: 'Recovery Mode', description: 'Deep calm session', type: 'grounding', icon: Icons.self_improvement_rounded, estimatedDuration: Duration(minutes: 10), route: '/recovery'),
            HealingJourneyStep(title: 'Journal', description: 'What would rest look like for you?', type: 'journal', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 10), route: '/journal'),
            HealingJourneyStep(title: 'Check-in', description: 'How does decompression feel?', type: 'checkin', icon: Icons.favorite_rounded, estimatedDuration: Duration(minutes: 2), route: '/mood-checkin'),
          ],
        ),
      ],
    ),

    // ── 3. Sleep Repair ─────────────────────
    GuidedHealingJourney(
      id: 'sleep_repair',
      title: 'Sleep Repair',
      subtitle: 'Heal your rest',
      emotionalIntent: 'From restless nights to healing sleep',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
      gradient: const LinearGradient(
        colors: [Color(0xFF0A1628), Color(0xFF122040)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '10 days',
      difficulty: 'gentle',
      tags: ['sleep', 'rest', 'calm'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Your Sleep Story',
          emotionalIntent: 'Understand your relationship with rest',
          steps: [
            HealingJourneyStep(title: 'Reflection', description: 'What keeps you awake at night?', type: 'reflection', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 5)),
            HealingJourneyStep(title: 'Sleep Sounds', description: 'Discover calming sounds', type: 'audio', icon: Icons.music_note_rounded, estimatedDuration: Duration(minutes: 10), route: '/audio'),
            HealingJourneyStep(title: 'Breathing', description: '4-7-8 sleep breathing', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
          ],
        ),
      ],
    ),

    // ── 4. Emotional Regulation ──────────────
    GuidedHealingJourney(
      id: 'emotional_regulation',
      title: 'Emotional Regulation',
      subtitle: 'Build emotional intelligence',
      emotionalIntent: 'From reactive to responsive',
      icon: Icons.water_drop_rounded,
      color: AppColors.novaPurple,
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1030), Color(0xFF251845)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '10 days',
      difficulty: 'moderate',
      tags: ['emotions', 'awareness', 'regulation'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Meeting Your Emotions',
          emotionalIntent: 'All emotions are valid visitors',
          steps: [
            HealingJourneyStep(title: 'Check-in', description: 'What emotion is present now?', type: 'checkin', icon: Icons.favorite_rounded, estimatedDuration: Duration(minutes: 3), route: '/mood-checkin'),
            HealingJourneyStep(title: 'Nova Guide', description: 'Understanding emotional waves', type: 'nova', icon: Icons.auto_awesome_rounded, estimatedDuration: Duration(minutes: 5), route: '/nova-chat'),
            HealingJourneyStep(title: 'Journal', description: 'Name 3 emotions from today', type: 'journal', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 5), route: '/journal'),
          ],
        ),
      ],
    ),

    // ── 5. Overthinking Recovery ────────────
    GuidedHealingJourney(
      id: 'overthinking_recovery',
      title: 'Overthinking Recovery',
      subtitle: 'Quiet the busy mind',
      emotionalIntent: 'From spiraling thoughts to gentle stillness',
      icon: Icons.cloud_rounded,
      color: AppColors.calmTeal,
      gradient: const LinearGradient(
        colors: [Color(0xFF0E2A2A), Color(0xFF153535)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '7 days',
      difficulty: 'gentle',
      tags: ['overthinking', 'calm', 'mental'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Thought Awareness',
          emotionalIntent: 'Observe thoughts without following them',
          steps: [
            HealingJourneyStep(title: 'Breathing', description: 'Slow breathing to anchor', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
            HealingJourneyStep(title: 'Grounding', description: '5 senses grounding', type: 'grounding', icon: Icons.spa_rounded, estimatedDuration: Duration(minutes: 5), route: '/grounding'),
            HealingJourneyStep(title: 'Journal', description: 'Brain dump — empty your mind on paper', type: 'journal', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 10), route: '/journal'),
          ],
        ),
      ],
    ),

    // ── 6. ADHD Calm & Focus ────────────────
    GuidedHealingJourney(
      id: 'adhd_calm',
      title: 'ADHD Calm & Focus',
      subtitle: 'Structured gentleness',
      emotionalIntent: 'From overstimulation to calm focus',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurpleLight,
      gradient: const LinearGradient(
        colors: [Color(0xFF1C1035), Color(0xFF2A1850)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '10 days',
      difficulty: 'moderate',
      tags: ['adhd', 'focus', 'calm'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Understanding Overstimulation',
          emotionalIntent: 'Your brain works differently, not wrongly',
          steps: [
            HealingJourneyStep(title: 'Nova Guide', description: 'ADHD and emotional regulation', type: 'nova', icon: Icons.auto_awesome_rounded, estimatedDuration: Duration(minutes: 5), route: '/nova-chat'),
            HealingJourneyStep(title: 'Breathing', description: 'Box breathing for reset', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
            HealingJourneyStep(title: 'Check-in', description: 'How focused do you feel?', type: 'checkin', icon: Icons.favorite_rounded, estimatedDuration: Duration(minutes: 2), route: '/mood-checkin'),
          ],
        ),
      ],
    ),

    // ── 7. Self-Compassion ──────────────────
    GuidedHealingJourney(
      id: 'self_compassion',
      title: 'Self-Compassion',
      subtitle: 'Be kind to yourself',
      emotionalIntent: 'From self-criticism to gentle acceptance',
      icon: Icons.favorite_rounded,
      color: AppColors.warmSupport,
      gradient: const LinearGradient(
        colors: [Color(0xFF2D1520), Color(0xFF3A1D2A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '7 days',
      difficulty: 'gentle',
      tags: ['compassion', 'healing', 'self-care'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Recognizing the Inner Critic',
          emotionalIntent: 'You are not your harshest thoughts',
          steps: [
            HealingJourneyStep(title: 'Journal', description: 'What does your inner critic say most?', type: 'journal', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 10), route: '/journal'),
            HealingJourneyStep(title: 'Nova Reflection', description: 'Reframing self-talk', type: 'nova', icon: Icons.auto_awesome_rounded, estimatedDuration: Duration(minutes: 5), route: '/nova-chat'),
            HealingJourneyStep(title: 'Breathing', description: 'Self-compassion breathing', type: 'breathing', icon: Icons.air_rounded, estimatedDuration: Duration(minutes: 5), route: '/breathing'),
          ],
        ),
      ],
    ),

    // ── 8. Social Anxiety Support ───────────
    GuidedHealingJourney(
      id: 'social_anxiety',
      title: 'Social Anxiety Support',
      subtitle: 'Ease into connection',
      emotionalIntent: 'From isolation to gentle confidence',
      icon: Icons.people_outline_rounded,
      color: AppColors.novaPurple,
      gradient: const LinearGradient(
        colors: [Color(0xFF151030), Color(0xFF201848)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      duration: '10 days',
      difficulty: 'moderate',
      isTherapistGuided: true,
      tags: ['social', 'anxiety', 'connection'],
      days: [
        const HealingJourneyDay(
          dayNumber: 1,
          theme: 'Understanding Social Fear',
          emotionalIntent: 'Fear of connection is a learned protection',
          steps: [
            HealingJourneyStep(title: 'Reflection', description: 'When does social anxiety appear?', type: 'reflection', icon: Icons.edit_note_rounded, estimatedDuration: Duration(minutes: 5)),
            HealingJourneyStep(title: 'Grounding', description: 'Body scan for tension', type: 'grounding', icon: Icons.spa_rounded, estimatedDuration: Duration(minutes: 5), route: '/grounding'),
            HealingJourneyStep(title: 'Check-in', description: 'How does reflecting feel?', type: 'checkin', icon: Icons.favorite_rounded, estimatedDuration: Duration(minutes: 2), route: '/mood-checkin'),
          ],
        ),
      ],
    ),
  ];

  static List<GuidedHealingJourney> get gentle =>
      all.where((j) => j.difficulty == 'gentle').toList();

  static List<GuidedHealingJourney> get therapistGuided =>
      all.where((j) => j.isTherapistGuided).toList();
}

// ==========================================
// COMPASSIONATE SETBACK MESSAGES
// ==========================================

class CompassionateMessages {
  CompassionateMessages._();

  static const List<String> pauseMessages = [
    'You paused, not failed.',
    'Healing allows rest too.',
    'You can continue whenever you feel ready.',
    'There is no timeline for recovery.',
    'Coming back is what matters most.',
  ];

  static const List<String> progressMessages = [
    "You've shown emotional consistency.",
    'Your nervous system seems calmer lately.',
    "You've returned even after difficult days.",
    'Small steps are still steps forward.',
    'Healing is not linear. You are doing it.',
  ];

  static const List<String> milestoneMessages = [
    'You completed a full week. That takes strength.',
    'Consistency is a form of self-love.',
    'You chose healing again today. That matters.',
  ];

  static String getPauseMessage() {
    final list = List<String>.from(pauseMessages)..shuffle();
    return list.first;
  }

  static String getProgressMessage() {
    final list = List<String>.from(progressMessages)..shuffle();
    return list.first;
  }
}
