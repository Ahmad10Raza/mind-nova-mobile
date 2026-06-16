import 'package:flutter/material.dart';
import '../../../core/design/colors/app_colors.dart';

// ==========================================
// NOVA PERSONALITY SYSTEM
// ==========================================

class NovaPersonality {
  NovaPersonality._();

  // ─── Core Traits ─────────────────────────────────────
  static const String name = 'Nova';
  static const String role = 'Emotional Wellness Companion';
  static const String philosophy =
      'I am here to emotionally guide, not to diagnose. I support, not replace. I listen, not lecture.';

  // ─── Communication Rules ─────────────────────────────
  // Nova ALWAYS:
  // - Validates emotions before suggesting actions
  // - Uses short, warm sentences
  // - Asks reflective questions
  // - Suggests (never commands)
  //
  // Nova NEVER:
  // - Uses toxic positivity ("Just be happy!")
  // - Acts overly cheerful when user is distressed
  // - Uses motivational clichés
  // - Diagnoses conditions
  // - Creates urgency

  // ─── Emotional Greetings (Time-based) ────────────────
  static String getGreeting(int hour) {
    if (hour < 6) return "Can't sleep? I'm here with you.";
    if (hour < 12) return 'Good morning. How are you feeling today?';
    if (hour < 17) return 'How has your afternoon been?';
    if (hour < 20) return 'How was today for you?';
    return "Winding down? Let's reflect gently.";
  }

  // ─── Conversation Starters ───────────────────────────
  static const List<NovaSuggestion> conversationStarters = [
    NovaSuggestion(
      text: "I'm feeling stressed",
      icon: Icons.cloud_rounded,
      color: AppColors.warmSupport,
    ),
    NovaSuggestion(
      text: "Help me calm down",
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
    ),
    NovaSuggestion(
      text: "I need to talk",
      icon: Icons.chat_bubble_outline_rounded,
      color: AppColors.novaPurple,
    ),
    NovaSuggestion(
      text: "I can't sleep",
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
    ),
  ];

  // ─── Inline Tool Recommendations ─────────────────────
  // Nova can suggest tools mid-conversation
  static const List<NovaToolRecommendation> toolRecommendations = [
    NovaToolRecommendation(
      trigger: 'anxiety',
      toolName: 'Breathing Exercise',
      route: '/breathing',
      message: 'A short breathing session might help right now.',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
    ),
    NovaToolRecommendation(
      trigger: 'sleep',
      toolName: 'Sleep Sounds',
      route: '/audio',
      message: 'Calming sounds helped you sleep better last week.',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
    ),
    NovaToolRecommendation(
      trigger: 'overwhelmed',
      toolName: 'Grounding Exercise',
      route: '/grounding',
      message: "Let's ground you with a quick 5-4-3-2-1 exercise.",
      icon: Icons.spa_rounded,
      color: AppColors.calmTeal,
    ),
    NovaToolRecommendation(
      trigger: 'reflect',
      toolName: 'Journal',
      route: '/journal',
      message: 'Writing your thoughts down often makes them clearer.',
      icon: Icons.edit_note_rounded,
      color: AppColors.novaPurple,
    ),
  ];
}

class NovaSuggestion {
  final String text;
  final IconData icon;
  final Color color;

  const NovaSuggestion({
    required this.text,
    required this.icon,
    required this.color,
  });
}

class NovaToolRecommendation {
  final String trigger;
  final String toolName;
  final String route;
  final String message;
  final IconData icon;
  final Color color;

  const NovaToolRecommendation({
    required this.trigger,
    required this.toolName,
    required this.route,
    required this.message,
    required this.icon,
    required this.color,
  });
}

// ==========================================
// GUIDED CONVERSATION FLOWS
// ==========================================

class NovaGuidedFlow {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String initialMessage;
  final List<String> toolRoutes;

  const NovaGuidedFlow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.initialMessage,
    required this.toolRoutes,
  });
}

class NovaGuidedFlows {
  NovaGuidedFlows._();

  static const List<NovaGuidedFlow> all = [
    NovaGuidedFlow(
      id: 'anxiety_support',
      title: 'Anxiety Support',
      subtitle: 'Calm your mind gently',
      icon: Icons.air_rounded,
      color: AppColors.calmTeal,
      initialMessage: "I notice you're feeling anxious. Let's slow things down together. Would you like to start with a breathing exercise, or would you prefer to talk first?",
      toolRoutes: ['/breathing', '/grounding'],
    ),
    NovaGuidedFlow(
      id: 'overwhelm_reset',
      title: 'Overwhelm Reset',
      subtitle: 'One step at a time',
      icon: Icons.spa_rounded,
      color: AppColors.warmSupport,
      initialMessage: "Feeling overwhelmed is your mind's way of saying it needs a pause. Let's start by grounding you, then we can talk through what's on your mind.",
      toolRoutes: ['/grounding', '/journal'],
    ),
    NovaGuidedFlow(
      id: 'sleep_support',
      title: 'Sleep Support',
      subtitle: 'Prepare for restful sleep',
      icon: Icons.bedtime_rounded,
      color: AppColors.recoveryBlue,
      initialMessage: "Struggling with sleep? Let's wind down together. I can guide you through a calming routine, or we can explore what's keeping you awake.",
      toolRoutes: ['/audio', '/breathing', '/sleep'],
    ),
    NovaGuidedFlow(
      id: 'emotional_reflection',
      title: 'Emotional Reflection',
      subtitle: 'Process and understand',
      icon: Icons.favorite_rounded,
      color: AppColors.novaPurple,
      initialMessage: "Sometimes emotions need space to be understood. There's no rush here. What's been on your mind?",
      toolRoutes: ['/journal', '/mood-checkin'],
    ),
    NovaGuidedFlow(
      id: 'loneliness_support',
      title: 'Loneliness Support',
      subtitle: "You're not alone",
      icon: Icons.people_rounded,
      color: AppColors.warmSupport,
      initialMessage: "Loneliness can be heavy. I'm here with you right now. Would you like to explore our community, or would talking help first?",
      toolRoutes: ['/community', '/groups'],
    ),
    NovaGuidedFlow(
      id: 'focus_recovery',
      title: 'Focus Recovery',
      subtitle: 'Reclaim your clarity',
      icon: Icons.center_focus_strong_rounded,
      color: AppColors.novaPurple,
      initialMessage: "Struggling to focus is often a sign that something deeper needs attention. Let's start small — would a grounding exercise or a focus session help?",
      toolRoutes: ['/focus', '/grounding'],
    ),
  ];
}
